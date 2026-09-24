# Get the rendered HTML of a JavaScript page in cURL

Get the rendered HTML of a JavaScript page with curl: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/curl/rendered-html](https://urlpipe.dev/code/curl/rendered-html).

## Before you start

curl is on every Mac and almost every Linux box. jq reads the token in the async script; install it from your package manager if `jq --version` finds nothing.

```bash
curl --version | head -1
jq --version        # brew install jq / apt install jq
export URLPIPE_API_KEY="your_api_key"
```

## Save the rendered HTML and report its size

`"sync": true` keeps the request open until the result is ready. `-w '%{http_code}'` hands you the status and `-o` parks the body in a file, so an error message is printed, not decoded or saved as if it were the result. `--max-time` stops a page that never finishes loading from hanging the script. `wc -c` counts bytes, the size you want.

[`rendered_html.sh`](rendered_html.sh)

```bash
bash rendered_html.sh
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away; `jq -r .token` pulls it out without quotes. The loop polls every two seconds and the `case` covers the four answers `GET /result/:token` can give.

[`rendered_html_async.sh`](rendered_html_async.sh)

```bash
bash rendered_html_async.sh
```

## Handle errors and retries

`-D` writes the response headers to a file, which is where Retry-After is read from. A 401 answers in plain text, so it is decided on the status alone; `jq` reads the `error` code of everything else.

[`rendered_html_errors.sh`](rendered_html_errors.sh)

```bash
bash rendered_html_errors.sh
```
