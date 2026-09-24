# Run a Lighthouse audit in Python

Run a Lighthouse audit with requests: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/python/lighthouse-audit](https://urlpipe.dev/code/python/lighthouse-audit).

## Before you start

One dependency, `requests`. Put your API key in the environment so it never lands in the file.

```bash
python3 -m pip install requests
export URLPIPE_API_KEY="your_api_key"
```

## Print the four scores, LCP, CLS and TBT

`"sync": True` holds the connection open until the result is ready and answers with it. Pass `timeout=` every time: requests has no default, and a page that never finishes loading would otherwise hang your process. Scores arrive from 0 to 1 and any of them can be `None` when Lighthouse could not compute it, so the loop checks before multiplying.

[`lighthouse_audit.py`](lighthouse_audit.py)

```bash
python3 lighthouse_audit.py
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away. `for … else` is the idiom for "ran out of attempts": the `else` runs only when the loop never hit `break`.

[`lighthouse_audit_async.py`](lighthouse_audit_async.py)

```bash
python3 lighthouse_audit_async.py
```

## Handle errors and retries

`raise_for_status()` is fine for a script; a service wants to tell the failures apart. Check the status before calling `res.json()` — a 401 body is not JSON. `sys.exit(message)` prints to stderr and exits 1.

[`lighthouse_audit_errors.py`](lighthouse_audit_errors.py)

```bash
python3 lighthouse_audit_errors.py
```
