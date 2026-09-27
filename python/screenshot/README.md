# Take a screenshot of a website in Python

Take a screenshot of a website with requests: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/python/screenshot](https://urlpipe.dev/code/python/screenshot).

## Before you start

One dependency, `requests`. Put your API key in the environment so it never lands in the file.

```bash
python3 -m pip install requests
export URLPIPE_API_KEY="your_api_key"
```

## Save a screenshot as a PNG file

`"sync": True` holds the connection open until the result is ready and answers with it. Pass `timeout=` every time: requests has no default, and a page that never finishes loading would otherwise hang your process. The body is the image as Base64 text, so `res.text` goes through `base64.b64decode` before it is written in binary mode.

[`screenshot.py`](screenshot.py)

```bash
python3 screenshot.py
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away. `for … else` is the idiom for "ran out of attempts": the `else` runs only when the loop never hit `break`.

[`screenshot_async.py`](screenshot_async.py)

```bash
python3 screenshot_async.py
```

## Handle errors and retries

`raise_for_status()` is fine for a script; a service wants to tell the failures apart. Check the status before calling `res.json()` — an error from a proxy in front of the API may not be JSON. `sys.exit(message)` prints to stderr and exits 1.

[`screenshot_errors.py`](screenshot_errors.py)

```bash
python3 screenshot_errors.py
```
