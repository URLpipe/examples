# URLpipe examples

Working programs for the [URLpipe API](https://urlpipe.dev): turn any URL into Markdown,
rendered HTML, a screenshot, metadata or a Lighthouse audit, with the page's
JavaScript run first. Every program here is the one published on
[https://urlpipe.dev/code](https://urlpipe.dev/code), complete from imports to exit code, and each is
run against a stub of the API before it is published.

Every task comes three ways — the sync request, the async variant (a token, a
webhook and a poll) and one with error handling and retries — plus a webhook
receiver that verifies signatures.

## Recipes

| | Python | Node.js | PHP | Ruby | Go | Java | C# | cURL |
|---|---|---|---|---|---|---|---|---|
| Take a screenshot of a website | [Python](python/screenshot) | [Node.js](node/screenshot) | [PHP](php/screenshot) | [Ruby](ruby/screenshot) | [Go](go/screenshot) | [Java](java/screenshot) | [C#](csharp/screenshot) | [cURL](curl/screenshot) |
| Convert a web page to Markdown | [Python](python/html-to-markdown) | [Node.js](node/html-to-markdown) | [PHP](php/html-to-markdown) | [Ruby](ruby/html-to-markdown) | [Go](go/html-to-markdown) | [Java](java/html-to-markdown) | [C#](csharp/html-to-markdown) | [cURL](curl/html-to-markdown) |
| Get the rendered HTML of a JavaScript page | [Python](python/rendered-html) | [Node.js](node/rendered-html) | [PHP](php/rendered-html) | [Ruby](ruby/rendered-html) | [Go](go/rendered-html) | [Java](java/rendered-html) | [C#](csharp/rendered-html) | [cURL](curl/rendered-html) |
| Get a page's metadata and Open Graph tags | [Python](python/page-metadata) | [Node.js](node/page-metadata) | [PHP](php/page-metadata) | [Ruby](ruby/page-metadata) | [Go](go/page-metadata) | [Java](java/page-metadata) | [C#](csharp/page-metadata) | [cURL](curl/page-metadata) |
| Run a Lighthouse audit | [Python](python/lighthouse-audit) | [Node.js](node/lighthouse-audit) | [PHP](php/lighthouse-audit) | [Ruby](ruby/lighthouse-audit) | [Go](go/lighthouse-audit) | [Java](java/lighthouse-audit) | [C#](csharp/lighthouse-audit) | [cURL](curl/lighthouse-audit) |
| Verify a webhook signature | [Python](python/verify-webhook) | [Node.js](node/verify-webhook) | [PHP](php/verify-webhook) | [Ruby](ruby/verify-webhook) | [Go](go/verify-webhook) | [Java](java/verify-webhook) | [C#](csharp/verify-webhook) | [cURL](curl/verify-webhook) |

## Integrations

- [n8n](integrations/n8n) — Call URLpipe from n8n's HTTP Request node — an importable workflow for sync calls, and a Webhook node for async results.
- [Pipedream](integrations/pipedream) — Call URLpipe from a Pipedream Node.js step with fetch, and use an HTTP trigger's endpoint as the webhook for async results.
- [Google Sheets](integrations/google-sheets) — Pull titles, descriptions and Lighthouse scores into a spreadsheet with a short Apps Script and UrlFetchApp.
- [Airtable](integrations/airtable) — Enrich Airtable records with page metadata and screenshot links from an automation's Run a script action.
- [LangChain](integrations/langchain) — langchain-urlpipe: four agent tools that read any page, JavaScript included, and a document loader for RAG.
- [LlamaIndex](integrations/llamaindex) — llama-index-readers-urlpipe: a reader that loads any page, JavaScript included, as a Markdown Document ready to index.

For AI agents, the hosted MCP server is set up in [URLpipe/mcp](https://github.com/URLpipe/mcp).

## Running them

1. [Sign up](https://urlpipe.dev) — 1,000 credits a month are free, no card — confirm your
   email, and copy your project's API key.
2. `export URLPIPE_API_KEY="your_api_key"`
3. Follow the README in the recipe's folder.

[API docs](https://urlpipe.dev/docs) · [OpenAPI spec](https://urlpipe.dev/openapi.json) · [Free tools](https://urlpipe.dev/tools) · contact@urlpipe.dev

---

This repository is generated from the site's recipe registry; changes made here
directly are overwritten. Found a bug in a program? Open an issue.
