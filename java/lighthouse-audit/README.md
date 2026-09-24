# Run a Lighthouse audit in Java

Run a Lighthouse audit with java.net.http.HttpClient: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/java/lighthouse-audit](https://urlpipe.dev/code/java/lighthouse-audit).

## Before you start

Java 17 or later: `java.net.http` is in the JDK. Every program on this page reads JSON, and the JDK has no parser, so those use Gson — one jar, no dependencies of its own. In a Maven or Gradle build add `com.google.code.gson:gson:2.13.1`; to try a file on its own, download the jar next to it.

```bash
java -version   # 17 or later
curl -sSLO https://repo1.maven.org/maven2/com/google/code/gson/gson/2.13.1/gson-2.13.1.jar
export URLPIPE_API_KEY="your_api_key"
```

## Print the four scores, LCP, CLS and TBT

`"sync": true` keeps the request open until the result is ready. `BodyHandlers.ofString()` reads the whole body as text, decoded with the charset the response names. HttpClient does not throw on a 4xx or 5xx, so check `statusCode()`. Gson's `JsonParser` reads the report; `dig` returns `null` for a category or metric Lighthouse could not compute.

[`LighthouseAudit.java`](LighthouseAudit.java)

```bash
java -cp gson-2.13.1.jar LighthouseAudit.java
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away. One `HttpClient` is shared by every call — it holds the connection pool, so build it once — and a switch expression covers the answers `GET /result/:token` can give.

[`LighthouseAuditAsync.java`](LighthouseAuditAsync.java)

```bash
java -cp gson-2.13.1.jar LighthouseAuditAsync.java
```

## Handle errors and retries

A checked `URLpipeException` makes the caller decide what a refusal means. `firstValueAsLong` reads Retry-After without a parse of your own, and a body that is not JSON (a 401 answers in plain text) falls back to an empty object.

[`LighthouseAuditErrors.java`](LighthouseAuditErrors.java)

```bash
java -cp gson-2.13.1.jar LighthouseAuditErrors.java
```
