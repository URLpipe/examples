# Verify a webhook signature in Node.js

A Node.js webhook receiver that checks the HMAC signature, the timestamp and a rotation.

The full walkthrough is at [https://urlpipe.dev/code/node/verify-webhook](https://urlpipe.dev/code/node/verify-webhook).

## Before you start

Nothing to install: `node:http` and `node:crypto` ship with Node. Turn signing on under **Settings → Webhook Signing** and copy the secret (it starts with `whsec_`).

```bash
export URLPIPE_WEBHOOK_SECRET="whsec_your_signing_secret"
```

## A receiver that verifies every delivery

`verify()` is the part to copy into your app. In Express, mount the route with `express.raw({ type: "application/json" })`, not `express.json()`, so `req.body` is the Buffer that was signed. `timingSafeEqual` throws on buffers of different lengths, which is why the length check comes first.

[`webhook.mjs`](webhook.mjs)

```bash
node webhook.mjs
```
