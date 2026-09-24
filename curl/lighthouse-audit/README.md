# Run a Lighthouse audit in cURL

Run a Lighthouse audit with curl: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/curl/lighthouse-audit](https://urlpipe.dev/code/curl/lighthouse-audit).

## Before you start

curl is on every Mac and almost every Linux box. jq reads the JSON this endpoint answers with; install it from your package manager if `jq --version` finds nothing.

```bash
curl --version | head -1
jq --version        # brew install jq / apt install jq
export URLPIPE_API_KEY="your_api_key"
```

## Print the four scores, LCP, CLS and TBT

`"sync": true` keeps the request open until the result is ready. `-w '%{http_code}'` hands you the status and `-o` parks the body in a file, so an error message is printed, not decoded or saved as if it were the result. `--max-time` stops a page that never finishes loading from hanging the script. One jq program prints the lot; `round` needs jq 1.6 or later.

[`lighthouse_audit.sh`](lighthouse_audit.sh)

```bash
bash lighthouse_audit.sh
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away; `jq -r .token` pulls it out without quotes. The loop polls every two seconds and the `case` covers the four answers `GET /result/:token` can give.

[`lighthouse_audit_async.sh`](lighthouse_audit_async.sh)

```bash
bash lighthouse_audit_async.sh
```

## Handle errors and retries

`-D` writes the response headers to a file, which is where Retry-After is read from. A 401 answers in plain text, so it is decided on the status alone; `jq` reads the `error` code of everything else.

[`lighthouse_audit_errors.sh`](lighthouse_audit_errors.sh)

```bash
bash lighthouse_audit_errors.sh
```
