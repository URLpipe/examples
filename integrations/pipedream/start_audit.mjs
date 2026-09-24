export default defineComponent({
  async run({ steps }) {
    const res = await fetch("https://urlpipe.dev/lighthouse", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${process.env.URLPIPE_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        url: steps.trigger.event.body.url,
        device: "mobile",
        report_to: "https://YOUR-ENDPOINT.m.pipedream.net",
        labels: { site: steps.trigger.event.body.site },
      }),
    });
    return await res.json(); // { token, status: "accepted", labels }
  },
});
