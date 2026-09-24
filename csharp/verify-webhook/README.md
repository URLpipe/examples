# Verify a webhook signature in C#

A C# webhook receiver that checks the HMAC signature, the timestamp and a rotation.

The full walkthrough is at [https://urlpipe.dev/code/csharp/verify-webhook](https://urlpipe.dev/code/csharp/verify-webhook).

## Before you start

An empty ASP.NET Core project is the whole setup; `System.Security.Cryptography` is in the base library. Turn signing on under **Settings → Webhook Signing** and copy the secret (it starts with `whsec_`).

```bash
dotnet new web -o UrlpipeWebhook && cd UrlpipeWebhook
export URLPIPE_WEBHOOK_SECRET="whsec_your_signing_secret"
# replace Program.cs with the receiver below, then:
dotnet run --urls http://localhost:8000
```

## A receiver that verifies every delivery

`Verify` is the part to copy into your app. Copy `Request.Body` into a `MemoryStream` and verify those bytes; model binding would parse and re-encode them. `CryptographicOperations.FixedTimeEquals` is the constant-time compare.

[`Program.cs`](Program.cs)

```bash
dotnet run --urls http://localhost:8000
```
