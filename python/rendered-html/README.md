# Get the rendered HTML of a JavaScript page in Python

Get the rendered HTML of a JavaScript page with requests: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/python/rendered-html](https://urlpipe.dev/code/python/rendered-html).

## Before you start

One dependency, `requests`. Put your API key in the environment so it never lands in the file.

```bash
python3 -m pip install requests
export URLPIPE_API_KEY="your_api_key"
```

## Save the rendered HTML and report its size

`"sync": True` holds the connection open until the result is ready and answers with it. Pass `timeout=` every time: requests has no default, and a page that never finishes loading would otherwise hang your process. Write `res.content` (bytes) rather than `res.text`, so the file is byte-for-byte what came back and its size is the real size.

[`rendered_html.py`](rendered_html.py)

```bash
python3 rendered_html.py
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away. `for … else` is the idiom for "ran out of attempts": the `else` runs only when the loop never hit `break`.

[`rendered_html_async.py`](rendered_html_async.py)

```bash
python3 rendered_html_async.py
```

## Handle errors and retries

`raise_for_status()` is fine for a script; a service wants to tell the failures apart. Check the status before calling `res.json()` — an error from a proxy in front of the API may not be JSON. `sys.exit(message)` prints to stderr and exits 1.

[`rendered_html_errors.py`](rendered_html_errors.py)

```bash
python3 rendered_html_errors.py
```
