import { writeFile } from "node:fs/promises";

const res = await fetch("https://urlpipe.dev/screenshot", {
  method: "POST",
  headers: {
    Authorization: `Bearer ${process.env.URLPIPE_API_KEY}`,
    "Content-Type": "application/json",
  },
  body: JSON.stringify({ url: "https://example.com", page_options: { block_cookie_banners: true }, sync: true }),
  // fetch has no timeout of its own; a sync call can take up to 60 s.
  signal: AbortSignal.timeout(90_000),
});
if (!res.ok) throw new Error(`URLpipe answered ${res.status}: ${await res.text()}`);

const png = Buffer.from(await res.text(), "base64");
await writeFile("screenshot.png", png);
console.log(`Saved screenshot.png (${png.length} bytes)`);
