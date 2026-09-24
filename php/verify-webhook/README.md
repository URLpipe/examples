# Verify a webhook signature in PHP

A PHP webhook receiver that checks the HMAC signature, the timestamp and a rotation.

The full walkthrough is at [https://urlpipe.dev/code/php/verify-webhook](https://urlpipe.dev/code/php/verify-webhook).

## Before you start

Nothing to install. Turn signing on under **Settings → Webhook Signing** and copy the secret (it starts with `whsec_`). PHP's built-in server is enough to try the receiver; in production the same file sits behind PHP-FPM.

```bash
export URLPIPE_WEBHOOK_SECRET="whsec_your_signing_secret"
```

## A receiver that verifies every delivery

`verify()` is the part to copy into your app — in Laravel pass it `$request->getContent()`. `php://input` is the raw body; `$_POST` is empty for JSON, and a `json_decode`/`json_encode` round trip changes the bytes. `hash_equals()` is the constant-time compare: never `===` on a signature.

[`webhook.php`](webhook.php)

```bash
php -S localhost:8000 webhook.php
```
