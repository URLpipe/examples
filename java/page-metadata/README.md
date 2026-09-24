# Get a page's metadata and Open Graph tags in Java

Get a page's metadata and Open Graph tags with java.net.http.HttpClient: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/java/page-metadata](https://urlpipe.dev/code/java/page-metadata).

## Before you start

Java 17 or later: `java.net.http` is in the JDK. Every program on this page reads JSON, and the JDK has no parser, so those use Gson — one jar, no dependencies of its own. In a Maven or Gradle build add `com.google.code.gson:gson:2.13.1`; to try a file on its own, download the jar next to it.

```bash
java -version   # 17 or later
curl -sSLO https://repo1.maven.org/maven2/com/google/code/gson/gson/2.13.1/gson-2.13.1.jar
export URLPIPE_API_KEY="your_api_key"
```

## Print the title, description and main image

`"sync": true` keeps the request open until the result is ready. `BodyHandlers.ofString()` reads the whole body as text, decoded with the charset the response names. HttpClient does not throw on a 4xx or 5xx, so check `statusCode()`. Gson's `JsonParser` reads the object; `dig` treats a missing field and a JSON `null` alike, since any field can be `null`.

[`PageMetadata.java`](PageMetadata.java)

```bash
java -cp gson-2.13.1.jar PageMetadata.java
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away. One `HttpClient` is shared by every call — it holds the connection pool, so build it once — and a switch expression covers the answers `GET /result/:token` can give.

[`PageMetadataAsync.java`](PageMetadataAsync.java)

```bash
java -cp gson-2.13.1.jar PageMetadataAsync.java
```

## Handle errors and retries

A checked `URLpipeException` makes the caller decide what a refusal means. `firstValueAsLong` reads Retry-After without a parse of your own, and a body that is not JSON (a 401 answers in plain text) falls back to an empty object.

[`PageMetadataErrors.java`](PageMetadataErrors.java)

```bash
java -cp gson-2.13.1.jar PageMetadataErrors.java
```
