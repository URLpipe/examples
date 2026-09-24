const res = await fetch("https://urlpipe.dev/meta", {
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

const meta = await res.json();
console.log(`Title: ${meta.title ?? "none"}`);
console.log(`Description: ${meta.description ?? "none"}`);
console.log(`Image: ${meta.main_image_url ?? "none"}`);
