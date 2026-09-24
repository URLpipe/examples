# Run a Lighthouse audit in Node.js

Run a Lighthouse audit with the built-in fetch: the request, the async variant and the error handling.

The full walkthrough is at [https://urlpipe.dev/code/node/lighthouse-audit](https://urlpipe.dev/code/node/lighthouse-audit).

## Before you start

Nothing to install: `fetch` is global from Node 18. The files end in `.mjs` so Node reads them as ES modules and top-level `await` works without a wrapper function.

```bash
node --version   # v18 or later
export URLPIPE_API_KEY="your_api_key"
```

## Print the four scores, LCP, CLS and TBT

`sync: true` keeps the request open until the result is ready. fetch resolves on any status, 4xx and 5xx included, so check `res.ok` yourself. Optional chaining (`?.`) covers a category or metric Lighthouse could not compute, which arrives as `null`.

[`lighthouse_audit.mjs`](lighthouse_audit.mjs)

```bash
node lighthouse_audit.mjs
```

## The async variant: a token, a webhook and a poll

Leave out `sync` and the answer is a token, straight away. `setTimeout` from `node:timers/promises` is the awaitable sleep, so the polling loop reads top to bottom.

[`lighthouse_audit_async.mjs`](lighthouse_audit_async.mjs)

```bash
node lighthouse_audit_async.mjs
```

## Handle errors and retries

Read the status before the body: a 401 answers in plain text, so `res.json()` would throw. `.catch(() => ({}))` turns any body that is not JSON into an empty object, and the status still says what happened.

[`lighthouse_audit_errors.mjs`](lighthouse_audit_errors.mjs)

```bash
node lighthouse_audit_errors.mjs
```
