import hashlib
import hmac
import json
import os
import time
from http.server import BaseHTTPRequestHandler, HTTPServer

SECRET = os.environ["URLPIPE_WEBHOOK_SECRET"].encode()
TOLERANCE = 5 * 60  # seconds


def verify(body: bytes, timestamp: str, signature_header: str) -> bool:
    """True when the delivery was signed with SECRET in the last five minutes."""
    if not timestamp.isdigit() or abs(time.time() - int(timestamp)) > TOLERANCE:
        return False
    signed = timestamp.encode() + b"." + body
    expected = ("v1=" + hmac.new(SECRET, signed, hashlib.sha256).hexdigest()).encode()
    # One signature normally, two during a secret rotation: accept any match.
    return any(hmac.compare_digest(s.strip().encode(), expected) for s in signature_header.split(","))


class Webhook(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path != "/webhooks/urlpipe":
            return self.reply(404)
        # The raw bytes, exactly as sent.
        body = self.rfile.read(int(self.headers.get("Content-Length", 0)))
        timestamp = self.headers.get("X-URLpipe-Timestamp", "")
        signature = self.headers.get("X-URLpipe-Signature", "")
        if not verify(body, timestamp, signature):
            return self.reply(401)

        delivery = json.loads(body)
        print(f"Verified delivery for {delivery['token']}", flush=True)
        self.reply(200)

    def reply(self, status):
        self.send_response(status)
        self.end_headers()


HTTPServer(("", int(os.environ.get("PORT", 8000))), Webhook).serve_forever()
