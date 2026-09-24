# Get the rendered HTML of a JavaScript page in Node.js

Get the rendered HTML of a JavaScript page with the built-in fetch: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/node/rendered-html](https://urlpipe.dev/code/node/rendered-html).

## Before you start

Nothing to install: `fetch` is global from Node 18. The files end in `.mjs` so Node reads them as ES modules and top-level `await` works without a wrapper function.

```bash
node --version   # v18 or later
export URLPIPE_API_KEY="your_api_key"
```

## Save the rendered HTML and report its size

`sync: true` keeps the request open until the result is ready. fetch resolves on any status, 4xx and 5xx included, so check `res.ok` yourself. `Buffer.byteLength` counts bytes; `html.length` would count UTF-16 code units and come out smaller on any page with non-ASCII text.

[`rendered_html.mjs`](rendered_html.mjs)

```bash
node rendered_html.mjs
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away. `setTimeout` from `node:timers/promises` is the awaitable sleep, so the polling loop reads top to bottom.

[`rendered_html_async.mjs`](rendered_html_async.mjs)

```bash
node rendered_html_async.mjs
```

## Handle errors and retries

Read the status before the body: a 401 answers in plain text, so `res.json()` would throw. `.catch(() => ({}))` turns any body that is not JSON into an empty object, and the status still says what happened.

[`rendered_html_errors.mjs`](rendered_html_errors.mjs)

```bash
node rendered_html_errors.mjs
```
