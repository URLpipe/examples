import os

import requests

res = requests.post(
    "https://urlpipe.dev/meta",
    headers={"Authorization": f"Bearer {os.environ['URLPIPE_API_KEY']}"},
    json={"url": "https://example.com", "sync": True},
    # requests waits forever unless told otherwise; a sync call can take up to 60 s.
    timeout=90,
)
res.raise_for_status()

meta = res.json()
print("Title:", meta["title"] or "none")
print("Description:", meta["description"] or "none")
print("Image:", meta["main_image_url"] or "none")
