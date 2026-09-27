# Convert a web page to Markdown in PHP

Convert a web page to Markdown with the curl extension: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/php/html-to-markdown](https://urlpipe.dev/code/php/html-to-markdown).

## Before you start

Nothing to install beyond PHP itself: the curl extension ships with it. Check it is loaded, and put your API key in the environment.

```bash
php -m | grep curl   # prints "curl"
export URLPIPE_API_KEY="your_api_key"
```

## Print a page as Markdown

Without `CURLOPT_RETURNTRANSFER`, `curl_exec()` prints the body and returns `true` — the most common reason a PHP example "returns nothing". `curl_exec()` returns `false` only when there was no HTTP answer at all; a 422 is still a string, so read the status too. The body is the Markdown itself, so `$body` is the whole job.

[`html_to_markdown.php`](html_to_markdown.php)

```bash
php html_to_markdown.php
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away. `send()` uses `CURLOPT_CUSTOMREQUEST` so one function makes both the POST and the GETs, and array destructuring (`[$status, $body] = …`) keeps the loop short.

[`html_to_markdown_async.php`](html_to_markdown_async.php)

```bash
php html_to_markdown_async.php
```

## Handle errors and retries

`json_decode()` returns `null` for a body that is not JSON (a proxy or load balancer in front of the API can answer in HTML), and `?: []` turns that into an empty array. `CURLOPT_HEADERFUNCTION` is how curl hands you response headers one line at a time.

[`html_to_markdown_errors.php`](html_to_markdown_errors.php)

```bash
php html_to_markdown_errors.php
```
