# Take a screenshot of a website in Node.js

Take a screenshot of a website with the built-in fetch: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/node/screenshot](https://urlpipe.dev/code/node/screenshot).

## Before you start

Nothing to install: `fetch` is global from Node 18. The files end in `.mjs` so Node reads them as ES modules and top-level `await` works without a wrapper function.

```bash
node --version   # v18 or later
export URLPIPE_API_KEY="your_api_key"
```

## Save a screenshot as a PNG file

`sync: true` keeps the request open until the result is ready. fetch resolves on any status, 4xx and 5xx included, so check `res.ok` yourself. The body is Base64 text; `Buffer.from(text, "base64")` turns it back into bytes.

[`screenshot.mjs`](screenshot.mjs)

```bash
node screenshot.mjs
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away. `setTimeout` from `node:timers/promises` is the awaitable sleep, so the polling loop reads top to bottom.

[`screenshot_async.mjs`](screenshot_async.mjs)

```bash
node screenshot_async.mjs
```

## Handle errors and retries

Read the status before the body: a 401 answers in plain text, so `res.json()` would throw. `.catch(() => ({}))` turns any body that is not JSON into an empty object, and the status still says what happened.

[`screenshot_errors.mjs`](screenshot_errors.mjs)

```bash
node screenshot_errors.mjs
```
