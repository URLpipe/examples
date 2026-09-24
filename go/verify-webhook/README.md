# Verify a webhook signature in Go

A Go webhook receiver that checks the HMAC signature, the timestamp and a rotation.

The full walkthrough is at [https://urlpipe.dev/code/go/verify-webhook](https://urlpipe.dev/code/go/verify-webhook).

## Before you start

Nothing to fetch: `crypto/hmac` and `net/http` are standard library. Turn signing on under **Settings → Webhook Signing** and copy the secret (it starts with `whsec_`).

```bash
export URLPIPE_WEBHOOK_SECRET="whsec_your_signing_secret"
```

## A receiver that verifies every delivery

`verify` is the part to copy into your service. Read `r.Body` with `io.ReadAll` and verify those bytes before you decode anything — decoding and re-encoding changes them. `hmac.Equal` is the constant-time compare.

[`main.go`](main.go)

```bash
go run main.go
```
