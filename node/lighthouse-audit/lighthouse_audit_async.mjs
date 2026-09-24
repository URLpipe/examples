import { setTimeout as sleep } from "node:timers/promises";

const API = "https://urlpipe.dev";
const headers = {
  Authorization: `Bearer ${process.env.URLPIPE_API_KEY}`,
  "Content-Type": "application/json",
};

// No sync: the request is accepted at once and the work carries on without you.
const accepted = await fetch(`${API}/lighthouse`, {
  method: "POST",
  headers,
  body: JSON.stringify({
    url: "https://example.com",
    device: "mobile",
    report_to: "https://your-app.com/webhooks/urlpipe",
    labels: { customer: "acme" },
  }),
});
if (!accepted.ok) throw new Error(`URLpipe answered ${accepted.status}: ${await accepted.text()}`);
const { token } = await accepted.json();
console.log(`Accepted ${token}`);

// The result is POSTed to report_to when it is ready. Polling by token is the
// other way to collect it: no endpoint needed, and a backup for the webhook.
let res;
for (let attempt = 0; attempt < 60; attempt++) {
  res = await fetch(`${API}/result/${token}`, { headers });
  if (res.status !== 202) break; // 202 means still processing
  await sleep(2000);
}
if (res.status === 202) throw new Error("Still processing after two minutes; try the token again later.");
if (res.status === 422) throw new Error(`The analysis failed: ${(await res.json()).error}`);
if (res.status === 410) throw new Error("The result is past the 30-day window; send the request again.");
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
