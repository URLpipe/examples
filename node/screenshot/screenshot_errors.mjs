import { setTimeout as sleep } from "node:timers/promises";
import { writeFile } from "node:fs/promises";

class URLpipeError extends Error {}

// POST a sync request and return the response, or throw URLpipeError.
async function urlpipe(path, payload, attempts = 5) {
  for (let attempt = 0; attempt < attempts; attempt++) {
    const res = await fetch(`https://urlpipe.dev${path}`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${process.env.URLPIPE_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ ...payload, sync: true }),
      signal: AbortSignal.timeout(90_000),
    });
    if (res.ok) return res;
    if (res.status === 401) {
      throw new URLpipeError("401: the API key is missing or wrong. Check URLPIPE_API_KEY.");
    }

    const body = await res.json().catch(() => ({}));
    const code = body.error ?? "";
    const detail = body.message ? `${code}: ${body.message}` : code;

    if (res.status === 429 && code === "rate_limited") {
      // Sending too fast: Retry-After says how long the window has left.
      await sleep(Number(res.headers.get("Retry-After") ?? 1) * 1000);
    } else if (res.status === 429 && code === "concurrency_limit") {
      // Every parallel slot on your plan is busy with your own requests.
      await sleep(2 ** attempt * 1000);
    } else if (res.status === 504) {
      // Still running on our side; the token collects it from GET /result/:token.
      throw new URLpipeError(`504 processing_timeout: collect it later with token ${body.token}`);
    } else {
      // 403 email_unverified, 422 (a bad parameter, or a page that would not load),
      // 429 quota_exceeded: sending the same request again gets the same answer.
      throw new URLpipeError(`${res.status}: ${detail}`);
    }
  }
  throw new URLpipeError(`429: still refused after ${attempts} attempts`);
}

let res;
try {
  res = await urlpipe("/screenshot", { url: "https://example.com", page_options: { block_cookie_banners: true } });
} catch (error) {
  console.error(`URLpipe: ${error.message}`);
  process.exit(1);
}

const png = Buffer.from(await res.text(), "base64");
await writeFile("screenshot.png", png);
console.log(`Saved screenshot.png (${png.length} bytes)`);
