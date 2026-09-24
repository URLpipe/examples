# Convert a web page to Markdown in Java

Convert a web page to Markdown with java.net.http.HttpClient: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/java/html-to-markdown](https://urlpipe.dev/code/java/html-to-markdown).

## Before you start

Java 17 or later: `java.net.http` is in the JDK. The async and error-handling programs read JSON, and the JDK has no parser, so those use Gson — one jar, no dependencies of its own. In a Maven or Gradle build add `com.google.code.gson:gson:2.13.1`; to try a file on its own, download the jar next to it.

```bash
java -version   # 17 or later
curl -sSLO https://repo1.maven.org/maven2/com/google/code/gson/gson/2.13.1/gson-2.13.1.jar
export URLPIPE_API_KEY="your_api_key"
```

## Print a page as Markdown

`"sync": true` keeps the request open until the result is ready. `BodyHandlers.ofString()` reads the whole body as text, decoded with the charset the response names. HttpClient does not throw on a 4xx or 5xx, so check `statusCode()`. The body is the Markdown itself, so the String is the whole job.

[`HtmlToMarkdown.java`](HtmlToMarkdown.java)

```bash
java HtmlToMarkdown.java
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away. One `HttpClient` is shared by every call — it holds the connection pool, so build it once — and a switch expression covers the answers `GET /result/:token` can give.

[`HtmlToMarkdownAsync.java`](HtmlToMarkdownAsync.java)

```bash
java -cp gson-2.13.1.jar HtmlToMarkdownAsync.java
```

## Handle errors and retries

A checked `URLpipeException` makes the caller decide what a refusal means. `firstValueAsLong` reads Retry-After without a parse of your own, and a body that is not JSON (a 401 answers in plain text) falls back to an empty object.

[`HtmlToMarkdownErrors.java`](HtmlToMarkdownErrors.java)

```bash
java -cp gson-2.13.1.jar HtmlToMarkdownErrors.java
```
