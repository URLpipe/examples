# Verify a webhook signature in Python

A Python webhook receiver that checks the HMAC signature, the timestamp and a rotation.

The full walkthrough is at [https://urlpipe.dev/code/python/verify-webhook](https://urlpipe.dev/code/python/verify-webhook).

## Before you start

Nothing to install: the receiver below is standard library only. Turn signing on under **Settings → Webhook Signing** and copy the secret (it starts with `whsec_`).

```bash
export URLPIPE_WEBHOOK_SECRET="whsec_your_signing_secret"
```

## A receiver that verifies every delivery

`verify()` is the part to copy into your app. In Flask pass it `request.get_data()`, in Django `request.body` — the raw bytes, never `request.json` re-serialized. `hmac.compare_digest` takes the same time whether the first byte or the last one differs, which is what stops a timing attack.

[`webhook.py`](webhook.py)

```bash
python3 webhook.py
```
