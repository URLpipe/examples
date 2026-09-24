import { writeFile } from "node:fs/promises";

const res = await fetch("https://urlpipe.dev/html", {
  method: "POST",
  headers: {
    Authorization: `Bearer ${process.env.URLPIPE_API_KEY}`,
    "Content-Type": "application/json",
  },
  body: JSON.stringify({ url: "https://example.com", sync: true }),
  // fetch has no timeout of its own; a sync call can take up to 60 s.
  signal: AbortSignal.timeout(90_000),
});
if (!res.ok) throw new Error(`URLpipe answered ${res.status}: ${await res.text()}`);

const html = await res.text();
await writeFile("page.html", html);
console.log(`Saved page.html (${Buffer.byteLength(html)} bytes)`);
