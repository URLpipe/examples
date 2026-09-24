import os

import requests

res = requests.post(
    "https://urlpipe.dev/markdown",
    headers={"Authorization": f"Bearer {os.environ['URLPIPE_API_KEY']}"},
    json={"url": "https://example.com", "sync": True},
    # requests waits forever unless told otherwise; a sync call can take up to 60 s.
    timeout=90,
)
res.raise_for_status()

# Plain text: pipe it into a file, a chunker or a prompt.
print(res.text)
