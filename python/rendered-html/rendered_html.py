import os

import requests

res = requests.post(
    "https://urlpipe.dev/html",
    headers={"Authorization": f"Bearer {os.environ['URLPIPE_API_KEY']}"},
    json={"url": "https://example.com", "sync": True},
    # requests waits forever unless told otherwise; a sync call can take up to 60 s.
    timeout=90,
)
res.raise_for_status()

with open("page.html", "wb") as f:
    f.write(res.content)
print(f"Saved page.html ({len(res.content)} bytes)")
