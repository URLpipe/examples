package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strconv"
	"time"
)

var client = &http.Client{Timeout: 90 * time.Second}

// urlpipe POSTs a sync request and returns the result body. It retries the two
// 429s that clear by themselves and returns an error for everything else.
func urlpipe(path string, payload map[string]any) ([]byte, error) {
	payload["sync"] = true
	data, err := json.Marshal(payload)
	if err != nil {
		return nil, err
	}

	const attempts = 5
	for attempt := 0; attempt < attempts; attempt++ {
		req, err := http.NewRequest(http.MethodPost, "https://urlpipe.dev"+path, bytes.NewReader(data))
		if err != nil {
			return nil, err
		}
		req.Header.Set("Authorization", "Bearer "+os.Getenv("URLPIPE_API_KEY"))
		req.Header.Set("Content-Type", "application/json")

		res, err := client.Do(req)
		if err != nil {
			return nil, err
		}
		body, err := io.ReadAll(res.Body)
		res.Body.Close()
		if err != nil {
			return nil, err
		}

		switch res.StatusCode {
		case http.StatusOK:
			return body, nil
		case http.StatusUnauthorized:
			return nil, errors.New("401: the API key is missing or wrong, check URLPIPE_API_KEY")
		}

		var e struct {
			Code    string `json:"error"`
			Message string `json:"message"`
			Token   string `json:"token"`
		}
		_ = json.Unmarshal(body, &e) // a body that is not JSON leaves e empty
		detail := e.Code
		if e.Message != "" {
			detail = e.Code + ": " + e.Message
		}

		switch {
		case res.StatusCode == http.StatusTooManyRequests && e.Code == "rate_limited":
			// Sending too fast: Retry-After says how long the window has left.
			seconds, _ := strconv.Atoi(res.Header.Get("Retry-After"))
			time.Sleep(time.Duration(max(seconds, 1)) * time.Second)
		case res.StatusCode == http.StatusTooManyRequests && e.Code == "concurrency_limit":
			// Every parallel slot on your plan is busy with your own requests.
			time.Sleep(time.Duration(1<<attempt) * time.Second)
		case res.StatusCode == http.StatusGatewayTimeout:
			// Still running on our side; the token collects it from GET /result/:token.
			return nil, fmt.Errorf("504 processing_timeout: collect it later with token %s", e.Token)
		default:
			// 403 email_unverified, 422 (a bad parameter, or a page that would not load),
			// 429 quota_exceeded: sending the same request again gets the same answer.
			return nil, fmt.Errorf("%d: %s", res.StatusCode, detail)
		}
	}
	return nil, fmt.Errorf("429: still refused after %d attempts", attempts)
}

func main() {
	body, err := urlpipe("/markdown", map[string]any{
		"url": "https://example.com",
	})
	if err != nil {
		log.Fatalf("URLpipe: %v", err)
	}

	// Plain text: pipe it into a file, a chunker or a prompt.
	fmt.Println(string(body))
}
