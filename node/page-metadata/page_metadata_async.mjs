import { setTimeout as sleep } from "node:timers/promises";

const API = "https://urlpipe.dev";
const headers = {
  Authorization: `Bearer ${process.env.URLPIPE_API_KEY}`,
  "Content-Type": "application/json",
};

// No sync: the request is accepted at once and the work carries on without you.
const accepted = await fetch(`${API}/meta`, {
  method: "POST",
  headers,
  body: JSON.stringify({
    url: "https://example.com",
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

const meta = await res.json();
console.log(`Title: ${meta.title ?? "none"}`);
console.log(`Description: ${meta.description ?? "none"}`);
console.log(`Image: ${meta.main_image_url ?? "none"}`);
