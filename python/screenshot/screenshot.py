import base64
import os

import requests

res = requests.post(
    "https://urlpipe.dev/screenshot",
    headers={"Authorization": f"Bearer {os.environ['URLPIPE_API_KEY']}"},
    json={"url": "https://example.com", "page_options": {"block_cookie_banners": True}, "sync": True},
    # requests waits forever unless told otherwise; a sync call can take up to 60 s.
    timeout=90,
)
res.raise_for_status()

png = base64.b64decode(res.text)
with open("screenshot.png", "wb") as f:
    f.write(png)
print(f"Saved screenshot.png ({len(png)} bytes)")
