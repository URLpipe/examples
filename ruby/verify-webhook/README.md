# Verify a webhook signature in Ruby

A Ruby webhook receiver that checks the HMAC signature, the timestamp and a rotation.

The full walkthrough is at [https://urlpipe.dev/code/ruby/verify-webhook](https://urlpipe.dev/code/ruby/verify-webhook).

## Before you start

The check itself needs only `openssl` from the standard library. The receiver is a Rack app, so it runs under `rackup` here and drops into Rails or Sinatra as it is. Turn signing on under **Settings → Webhook Signing** and copy the secret (it starts with `whsec_`).

```bash
gem install rackup puma
export URLPIPE_WEBHOOK_SECRET="whsec_your_signing_secret"
```

## A receiver that verifies every delivery

`verify` is the part to copy into your app. In a Rails controller pass it `request.raw_post` — the bytes that were signed — never `params` re-encoded. `OpenSSL.secure_compare` is constant-time and safe on strings of different lengths.

[`config.ru`](config.ru)

```bash
rackup config.ru -p 8000
```
