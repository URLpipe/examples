const { recordId, url } = input.config();
const headers = {
  Authorization: `Bearer ${input.secret("urlpipe_api_key")}`,
  "Content-Type": "application/json",
};

// 1. Title, description and image
const metaRes = await fetch("https://urlpipe.dev/meta", {
  method: "POST",
  headers,
  body: JSON.stringify({ url, sync: true }),
});
if (!metaRes.ok) throw new Error(`URLpipe /meta ${metaRes.status}: ${await metaRes.text()}`);
const meta = await metaRes.json();

// 2. A first-screen screenshot, as a link that needs no key
const shotRes = await fetch("https://urlpipe.dev/screenshot", {
  method: "POST",
  headers,
  body: JSON.stringify({
    url,
    sync: true,
    screenshot_options: { full_page: false, format: "webp" },
    page_options: { block_cookie_banners: true },
  }),
});

const table = base.getTable("Links");
await table.updateRecordAsync(recordId, {
  Title: meta.title ?? "",
  Description: meta.description ?? "",
  Image: meta.main_image_url ?? null,
  Screenshot: shotRes.ok ? shotRes.headers.get("X-Result-Url") : null,
});
