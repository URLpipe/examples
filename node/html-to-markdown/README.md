# Convert a web page to Markdown in Node.js

Convert a web page to Markdown with the built-in fetch: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/node/html-to-markdown](https://urlpipe.dev/code/node/html-to-markdown).

## Before you start

Nothing to install: `fetch` is global from Node 18. The files end in `.mjs` so Node reads them as ES modules and top-level `await` works without a wrapper function.

```bash
node --version   # v18 or later
export URLPIPE_API_KEY="your_api_key"
```

## Print a page as Markdown

`sync: true` keeps the request open until the result is ready. fetch resolves on any status, 4xx and 5xx included, so check `res.ok` yourself. The body is the Markdown itself: `await res.text()` and you are done.

[`html_to_markdown.mjs`](html_to_markdown.mjs)

```bash
node html_to_markdown.mjs
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away. `setTimeout` from `node:timers/promises` is the awaitable sleep, so the polling loop reads top to bottom.

[`html_to_markdown_async.mjs`](html_to_markdown_async.mjs)

```bash
node html_to_markdown_async.mjs
```

## Handle errors and retries

Read the status before the body: a 401 answers in plain text, so `res.json()` would throw. `.catch(() => ({}))` turns any body that is not JSON into an empty object, and the status still says what happened.

[`html_to_markdown_errors.mjs`](html_to_markdown_errors.mjs)

```bash
node html_to_markdown_errors.mjs
```
