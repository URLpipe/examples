export default defineComponent({
  async run({ steps, $ }) {
    const url = steps.trigger.event.body?.url ?? "https://example.com";

    const res = await fetch("https://urlpipe.dev/markdown", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${process.env.URLPIPE_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ url, sync: true }),
    });

    if (!res.ok) {
      const { error } = await res.json().catch(() => ({}));
      throw new Error(`URLpipe ${res.status}: ${error ?? "request failed"}`);
    }

    $.export("$summary", `Read ${url}`);
    return await res.text(); // the Markdown, as steps.<this_step>.$return_value
  },
});
