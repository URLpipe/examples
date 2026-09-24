# Verify a webhook signature in cURL

The signature check for cURL — the shell's test tools, since a shell is no place to receive one.

The full walkthrough is at [https://urlpipe.dev/code/curl/verify-webhook](https://urlpipe.dev/code/curl/verify-webhook).

## Before you start

A shell is the wrong place to _receive_ webhooks, and a string comparison in bash is not constant-time, so the production check belongs in your application — see the other languages below. What the shell is good for: sending your receiver a correctly signed test delivery, and checking a delivery you captured. Both need only curl and openssl.

```bash
openssl version
export URLPIPE_WEBHOOK_SECRET="whsec_your_signing_secret"
```

## Send your receiver a signed test delivery

Signs a sample payload exactly as URLpipe signs a real one — HMAC-SHA256 over the timestamp, a dot and the raw body — so you can test your endpoint before turning signing on. `--data-binary` sends the body byte for byte; `-d` would strip newlines.

[`send_signed_delivery.sh`](send_signed_delivery.sh)

```bash
bash send_signed_delivery.sh
```

## Check a delivery you captured

Save the raw body of a delivery to a file (your receiver's logs, or a request inspector) and pass the two header values. The script recomputes the signature and says whether any value in the header matches and how old the timestamp is.

[`check_signature.sh`](check_signature.sh)

```bash
bash check_signature.sh TIMESTAMP 'v1=…' body.json
```
