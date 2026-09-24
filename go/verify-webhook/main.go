package main

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"
)

const tolerance = 5 * time.Minute

var secret = []byte(os.Getenv("URLPIPE_WEBHOOK_SECRET"))

// verify reports whether the delivery was signed with secret in the last five minutes.
func verify(body []byte, timestamp, signatureHeader string) bool {
	seconds, err := strconv.ParseInt(timestamp, 10, 64)
	if err != nil || time.Since(time.Unix(seconds, 0)).Abs() > tolerance {
		return false
	}
	mac := hmac.New(sha256.New, secret)
	mac.Write([]byte(timestamp + "."))
	mac.Write(body)
	expected := []byte("v1=" + hex.EncodeToString(mac.Sum(nil)))

	// One signature normally, two during a secret rotation: accept any match.
	for _, signature := range strings.Split(signatureHeader, ",") {
		if hmac.Equal([]byte(strings.TrimSpace(signature)), expected) {
			return true
		}
	}
	return false
}

func webhook(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	// The raw bytes, exactly as sent.
	body, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "unreadable body", http.StatusBadRequest)
		return
	}
	if !verify(body, r.Header.Get("X-URLpipe-Timestamp"), r.Header.Get("X-URLpipe-Signature")) {
		http.Error(w, "invalid signature", http.StatusUnauthorized)
		return
	}

	var delivery struct {
		Token string `json:"token"`
	}
	if err := json.Unmarshal(body, &delivery); err != nil {
		http.Error(w, "invalid JSON", http.StatusBadRequest)
		return
	}
	log.Printf("Verified delivery for %s", delivery.Token)
	w.WriteHeader(http.StatusOK)
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8000"
	}
	http.HandleFunc("/webhooks/urlpipe", webhook)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
