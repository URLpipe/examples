# Take a screenshot of a website in PHP

Take a screenshot of a website with the curl extension: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/php/screenshot](https://urlpipe.dev/code/php/screenshot).

## Before you start

Nothing to install beyond PHP itself: the curl extension ships with it. Check it is loaded, and put your API key in the environment.

```bash
php -m | grep curl   # prints "curl"
export URLPIPE_API_KEY="your_api_key"
```

## Save a screenshot as a PNG file

Without `CURLOPT_RETURNTRANSFER`, `curl_exec()` prints the body and returns `true` — the most common reason a PHP example "returns nothing". `curl_exec()` returns `false` only when there was no HTTP answer at all; a 422 is still a string, so read the status too. The body is the image as Base64 text; `base64_decode()` gives the bytes back.

[`screenshot.php`](screenshot.php)

```bash
php screenshot.php
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away. `send()` uses `CURLOPT_CUSTOMREQUEST` so one function makes both the POST and the GETs, and array destructuring (`[$status, $body] = …`) keeps the loop short.

[`screenshot_async.php`](screenshot_async.php)

```bash
php screenshot_async.php
```

## Handle errors and retries

`json_decode()` returns `null` for a body that is not JSON (a proxy or load balancer in front of the API can answer in HTML), and `?: []` turns that into an empty array. `CURLOPT_HEADERFUNCTION` is how curl hands you response headers one line at a time.

[`screenshot_errors.php`](screenshot_errors.php)

```bash
php screenshot_errors.php
```
