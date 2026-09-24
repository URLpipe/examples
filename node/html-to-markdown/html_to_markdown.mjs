const res = await fetch("https://urlpipe.dev/markdown", {
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

// Plain text: pipe it into a file, a chunker or a prompt.
console.log(await res.text());
