# Take a screenshot of a website in Go

Take a screenshot of a website with net/http from the standard library: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/go/screenshot](https://urlpipe.dev/code/go/screenshot).

## Before you start

Nothing to fetch: every import is standard library, so each program runs with `go run` as a single file. Put your API key in the environment.

```bash
go version   # go1.21 or later
export URLPIPE_API_KEY="your_api_key"
```

## Save a screenshot as a PNG file

`"sync": true` keeps the request open until the result is ready. `http.Client` has no timeout unless you set one, and `res.Body` is a stream: `io.ReadAll` turns it into bytes, and `defer res.Body.Close()` hands the connection back. The body is Base64 text; `base64.StdEncoding.DecodeString` gives the bytes back.

[`main.go`](main.go)

```bash
go run main.go
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away. Decode only the field you need into an anonymous struct; `switch` on the status covers the four answers `GET /result/:token` can give.

[`main.go`](main.go)

```bash
go run main.go
```

## Handle errors and retries

Errors are values: `urlpipe()` returns one for every refusal it will not retry, and `main` decides what to do with it. A 401 answers in plain text, so it is handled before the JSON decode; `max` is a builtin from Go 1.21.

[`main.go`](main.go)

```bash
go run main.go
```
