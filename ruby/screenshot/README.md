# Take a screenshot of a website in Ruby

Take a screenshot of a website with Net::HTTP from the standard library: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/ruby/screenshot](https://urlpipe.dev/code/ruby/screenshot).

## Before you start

Nothing to install: `net/http` and `json` are part of Ruby. Put your API key in the environment so it never lands in the file.

```bash
ruby --version   # 3.1 or later
export URLPIPE_API_KEY="your_api_key"
```

## Save a screenshot as a PNG file

`sync: true` keeps the request open until the result is ready. `use_ssl:` has to be asked for — Net::HTTP does not infer it from the scheme — and `abort` prints to stderr and exits 1. The body is Base64 text; `unpack1("m")` decodes it without requiring the `base64` gem, which is a bundled gem rather than a default one from Ruby 3.4.

[`screenshot.rb`](screenshot.rb)

```bash
ruby screenshot.rb
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away. Net::HTTP reports the status as a string, so the poll compares `res.code` with `"202"`, not the number.

[`screenshot_async.rb`](screenshot_async.rb)

```bash
ruby screenshot_async.rb
```

## Handle errors and retries

Pattern matching on `[status, code]` keeps the retry rules in one place. A 401 answers in plain text, so it is checked before `JSON.parse`, and a body that still is not JSON becomes an empty hash.

[`screenshot_errors.rb`](screenshot_errors.rb)

```bash
ruby screenshot_errors.rb
```
