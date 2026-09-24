const res = await fetch("https://urlpipe.dev/lighthouse", {
  method: "POST",
  headers: {
    Authorization: `Bearer ${process.env.URLPIPE_API_KEY}`,
    "Content-Type": "application/json",
  },
  body: JSON.stringify({ url: "https://example.com", device: "mobile", sync: true }),
  // fetch has no timeout of its own; a sync call can take up to 60 s.
  signal: AbortSignal.timeout(90_000),
});
if (!res.ok) throw new Error(`URLpipe answered ${res.status}: ${await res.text()}`);

const report = await res.json();
for (const name of ["performance", "accessibility", "best-practices", "seo"]) {
  const score = report.categories[name]?.score;
  console.log(`${name}: ${score == null ? "n/a" : Math.round(score * 100)}`);
}

const metrics = {
  LCP: "largest-contentful-paint",
  CLS: "cumulative-layout-shift",
  TBT: "total-blocking-time",
};
for (const [label, key] of Object.entries(metrics)) {
  console.log(`${label}: ${report.metrics[key]?.displayValue ?? "n/a"}`);
}
