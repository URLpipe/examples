# Convert a web page to Markdown in Ruby

Convert a web page to Markdown with Net::HTTP from the standard library: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/ruby/html-to-markdown](https://urlpipe.dev/code/ruby/html-to-markdown).

## Before you start

Nothing to install: `net/http` and `json` are part of Ruby. Put your API key in the environment so it never lands in the file.

```bash
ruby --version   # 3.1 or later
export URLPIPE_API_KEY="your_api_key"
```

## Print a page as Markdown

`sync: true` keeps the request open until the result is ready. `use_ssl:` has to be asked for — Net::HTTP does not infer it from the scheme — and `abort` prints to stderr and exits 1. The body is the Markdown itself: `res.body` is the whole job.

[`html_to_markdown.rb`](html_to_markdown.rb)

```bash
ruby html_to_markdown.rb
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away. Net::HTTP reports the status as a string, so the poll compares `res.code` with `"202"`, not the number.

[`html_to_markdown_async.rb`](html_to_markdown_async.rb)

```bash
ruby html_to_markdown_async.rb
```

## Handle errors and retries

Pattern matching on `[status, code]` keeps the retry rules in one place. A 401 answers in plain text, so it is checked before `JSON.parse`, and a body that still is not JSON becomes an empty hash.

[`html_to_markdown_errors.rb`](html_to_markdown_errors.rb)

```bash
ruby html_to_markdown_errors.rb
```
