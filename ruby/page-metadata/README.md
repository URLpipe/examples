# Get a page's metadata and Open Graph tags in Ruby

Get a page's metadata and Open Graph tags with Net::HTTP from the standard library: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/ruby/page-metadata](https://urlpipe.dev/code/ruby/page-metadata).

## Before you start

Nothing to install: `net/http` and `json` are part of Ruby. Put your API key in the environment so it never lands in the file.

```bash
ruby --version   # 3.1 or later
export URLPIPE_API_KEY="your_api_key"
```

## Print the title, description and main image

`sync: true` keeps the request open until the result is ready. `use_ssl:` has to be asked for — Net::HTTP does not infer it from the scheme — and `abort` prints to stderr and exits 1. Any field can be `nil`, hence the `|| "none"`.

[`page_metadata.rb`](page_metadata.rb)

```bash
ruby page_metadata.rb
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away. Net::HTTP reports the status as a string, so the poll compares `res.code` with `"202"`, not the number.

[`page_metadata_async.rb`](page_metadata_async.rb)

```bash
ruby page_metadata_async.rb
```

## Handle errors and retries

Pattern matching on `[status, code]` keeps the retry rules in one place. A 401 answers in plain text, so it is checked before `JSON.parse`, and a body that still is not JSON becomes an empty hash.

[`page_metadata_errors.rb`](page_metadata_errors.rb)

```bash
ruby page_metadata_errors.rb
```
