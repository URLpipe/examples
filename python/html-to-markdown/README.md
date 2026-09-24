# Convert a web page to Markdown in Python

Convert a web page to Markdown with requests: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/python/html-to-markdown](https://urlpipe.dev/code/python/html-to-markdown).

## Before you start

One dependency, `requests`. Put your API key in the environment so it never lands in the file.

```bash
python3 -m pip install requests
export URLPIPE_API_KEY="your_api_key"
```

## Print a page as Markdown

`"sync": True` holds the connection open until the result is ready and answers with it. Pass `timeout=` every time: requests has no default, and a page that never finishes loading would otherwise hang your process. The body is the Markdown itself, so `res.text` is the whole job.

[`html_to_markdown.py`](html_to_markdown.py)

```bash
python3 html_to_markdown.py
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away. `for … else` is the idiom for "ran out of attempts": the `else` runs only when the loop never hit `break`.

[`html_to_markdown_async.py`](html_to_markdown_async.py)

```bash
python3 html_to_markdown_async.py
```

## Handle errors and retries

`raise_for_status()` is fine for a script; a service wants to tell the failures apart. Check the status before calling `res.json()` — a 401 body is not JSON. `sys.exit(message)` prints to stderr and exits 1.

[`html_to_markdown_errors.py`](html_to_markdown_errors.py)

```bash
python3 html_to_markdown_errors.py
```
