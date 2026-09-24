import { createHmac, timingSafeEqual } from "node:crypto";
import { createServer } from "node:http";

const SECRET = process.env.URLPIPE_WEBHOOK_SECRET;
const TOLERANCE = 5 * 60; // seconds

// True when the delivery was signed with SECRET in the last five minutes.
function verify(body, timestamp, signatureHeader) {
  if (!/^\d+$/.test(timestamp) || Math.abs(Date.now() / 1000 - Number(timestamp)) > TOLERANCE) {
    return false;
  }
  const hmac = createHmac("sha256", SECRET).update(`${timestamp}.`).update(body);
  const expected = Buffer.from(`v1=${hmac.digest("hex")}`);
  // One signature normally, two during a secret rotation: accept any match.
  return signatureHeader.split(",").some((signature) => {
    const candidate = Buffer.from(signature.trim());
    return candidate.length === expected.length && timingSafeEqual(candidate, expected);
  });
}

createServer((req, res) => {
  if (req.method !== "POST" || req.url !== "/webhooks/urlpipe") {
    res.writeHead(404).end();
    return;
  }
  const chunks = [];
  req.on("data", (chunk) => chunks.push(chunk));
  req.on("end", () => {
    // The raw bytes, exactly as sent.
    const body = Buffer.concat(chunks);
    const timestamp = req.headers["x-urlpipe-timestamp"] ?? "";
    const signature = req.headers["x-urlpipe-signature"] ?? "";
    if (!verify(body, timestamp, signature)) {
      res.writeHead(401).end();
      return;
    }

    const { token } = JSON.parse(body);
    console.log(`Verified delivery for ${token}`);
    res.writeHead(200).end();
  });
}).listen(Number(process.env.PORT ?? 8000));
