# Verify a webhook signature in Java

A Java webhook receiver that checks the HMAC signature, the timestamp and a rotation.

The full walkthrough is at [https://urlpipe.dev/code/java/verify-webhook](https://urlpipe.dev/code/java/verify-webhook).

## Before you start

Nothing to add: `javax.crypto` computes the HMAC and the JDK's own `com.sun.net.httpserver` serves the endpoint, so the receiver runs from source with no jar. Turn signing on under **Settings → Webhook Signing** and copy the secret (it starts with `whsec_`).

```bash
export URLPIPE_WEBHOOK_SECRET="whsec_your_signing_secret"
```

## A receiver that verifies every delivery

`verify` is the part to copy into your service. In Spring, take the body as `@RequestBody byte[]` so you verify the bytes that were signed. `MessageDigest.isEqual` is the constant-time compare; `String.equals` stops at the first difference and leaks where it was.

[`WebhookReceiver.java`](WebhookReceiver.java)

```bash
java WebhookReceiver.java
```
