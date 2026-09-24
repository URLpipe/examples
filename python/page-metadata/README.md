# Get a page's metadata and Open Graph tags in Python

Get a page's metadata and Open Graph tags with requests: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/python/page-metadata](https://urlpipe.dev/code/python/page-metadata).

## Before you start

One dependency, `requests`. Put your API key in the environment so it never lands in the file.

```bash
python3 -m pip install requests
export URLPIPE_API_KEY="your_api_key"
```

## Print the title, description and main image

`"sync": True` holds the connection open until the result is ready and answers with it. Pass `timeout=` every time: requests has no default, and a page that never finishes loading would otherwise hang your process. `res.json()` gives a dict; any field can be `None`, hence the `or "none"`.

[`page_metadata.py`](page_metadata.py)

```bash
python3 page_metadata.py
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away. `for … else` is the idiom for "ran out of attempts": the `else` runs only when the loop never hit `break`.

[`page_metadata_async.py`](page_metadata_async.py)

```bash
python3 page_metadata_async.py
```

## Handle errors and retries

`raise_for_status()` is fine for a script; a service wants to tell the failures apart. Check the status before calling `res.json()` — a 401 body is not JSON. `sys.exit(message)` prints to stderr and exits 1.

[`page_metadata_errors.py`](page_metadata_errors.py)

```bash
python3 page_metadata_errors.py
```
