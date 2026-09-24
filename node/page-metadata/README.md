# Get a page's metadata and Open Graph tags in Node.js

Get a page's metadata and Open Graph tags with the built-in fetch: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/node/page-metadata](https://urlpipe.dev/code/node/page-metadata).

## Before you start

Nothing to install: `fetch` is global from Node 18. The files end in `.mjs` so Node reads them as ES modules and top-level `await` works without a wrapper function.

```bash
node --version   # v18 or later
export URLPIPE_API_KEY="your_api_key"
```

## Print the title, description and main image

`sync: true` keeps the request open until the result is ready. fetch resolves on any status, 4xx and 5xx included, so check `res.ok` yourself. Any field can be `null`; `??` gives it a fallback without also swallowing an empty string.

[`page_metadata.mjs`](page_metadata.mjs)

```bash
node page_metadata.mjs
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away. `setTimeout` from `node:timers/promises` is the awaitable sleep, so the polling loop reads top to bottom.

[`page_metadata_async.mjs`](page_metadata_async.mjs)

```bash
node page_metadata_async.mjs
```

## Handle errors and retries

Read the status before the body: a 401 answers in plain text, so `res.json()` would throw. `.catch(() => ({}))` turns any body that is not JSON into an empty object, and the status still says what happened.

[`page_metadata_errors.mjs`](page_metadata_errors.mjs)

```bash
node page_metadata_errors.mjs
```
