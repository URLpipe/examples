# Get a page's metadata and Open Graph tags in PHP

Get a page's metadata and Open Graph tags with the curl extension: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/php/page-metadata](https://urlpipe.dev/code/php/page-metadata).

## Before you start

Nothing to install beyond PHP itself: the curl extension ships with it. Check it is loaded, and put your API key in the environment.

```bash
php -m | grep curl   # prints "curl"
export URLPIPE_API_KEY="your_api_key"
```

## Print the title, description and main image

Without `CURLOPT_RETURNTRANSFER`, `curl_exec()` prints the body and returns `true` — the most common reason a PHP example "returns nothing". `curl_exec()` returns `false` only when there was no HTTP answer at all; a 422 is still a string, so read the status too. `json_decode($body, true)` gives an associative array; `??` covers a field that came back `null`.

[`page_metadata.php`](page_metadata.php)

```bash
php page_metadata.php
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away. `send()` uses `CURLOPT_CUSTOMREQUEST` so one function makes both the POST and the GETs, and array destructuring (`[$status, $body] = …`) keeps the loop short.

[`page_metadata_async.php`](page_metadata_async.php)

```bash
php page_metadata_async.php
```

## Handle errors and retries

`json_decode()` returns `null` for a body that is not JSON (a 401 answers in plain text), and `?: []` turns that into an empty array. `CURLOPT_HEADERFUNCTION` is how curl hands you response headers one line at a time.

[`page_metadata_errors.php`](page_metadata_errors.php)

```bash
php page_metadata_errors.php
```
