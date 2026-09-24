# Run a Lighthouse audit in Ruby

Run a Lighthouse audit with Net::HTTP from the standard library: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/ruby/lighthouse-audit](https://urlpipe.dev/code/ruby/lighthouse-audit).

## Before you start

Nothing to install: `net/http` and `json` are part of Ruby. Put your API key in the environment so it never lands in the file.

```bash
ruby --version   # 3.1 or later
export URLPIPE_API_KEY="your_api_key"
```

## Print the four scores, LCP, CLS and TBT

`sync: true` keeps the request open until the result is ready. `use_ssl:` has to be asked for — Net::HTTP does not infer it from the scheme — and `abort` prints to stderr and exits 1. `dig` walks the nested keys and returns `nil` for a category or metric Lighthouse could not compute.

[`lighthouse_audit.rb`](lighthouse_audit.rb)

```bash
ruby lighthouse_audit.rb
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away. Net::HTTP reports the status as a string, so the poll compares `res.code` with `"202"`, not the number.

[`lighthouse_audit_async.rb`](lighthouse_audit_async.rb)

```bash
ruby lighthouse_audit_async.rb
```

## Handle errors and retries

Pattern matching on `[status, code]` keeps the retry rules in one place. A 401 answers in plain text, so it is checked before `JSON.parse`, and a body that still is not JSON becomes an empty hash.

[`lighthouse_audit_errors.rb`](lighthouse_audit_errors.rb)

```bash
ruby lighthouse_audit_errors.rb
```
