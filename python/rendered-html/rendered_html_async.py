import os
import time

import requests

API = "https://urlpipe.dev"
HEADERS = {"Authorization": f"Bearer {os.environ['URLPIPE_API_KEY']}"}

# No "sync": the request is accepted at once and the work carries on without you.
res = requests.post(
    f"{API}/html",
    headers=HEADERS,
    json={
        "url": "https://example.com",
        "report_to": "https://your-app.com/webhooks/urlpipe",
        "labels": {"customer": "acme"},
    },
    timeout=30,
)
res.raise_for_status()
token = res.json()["token"]
print(f"Accepted {token}")

# The result is POSTed to report_to when it is ready. Polling by token is the
# other way to collect it: no endpoint needed, and a backup for the webhook.
for _ in range(60):
    res = requests.get(f"{API}/result/{token}", headers=HEADERS, timeout=30)
    if res.status_code != 202:  # 202 means still processing
        break
    time.sleep(2)
else:
    raise SystemExit("Still processing after two minutes; try the token again later.")

if res.status_code == 422:
    raise SystemExit(f"The analysis failed: {res.json()['error']}")
if res.status_code == 410:
    raise SystemExit("The result is past the 30-day window; send the request again.")
res.raise_for_status()

with open("page.html", "wb") as f:
    f.write(res.content)
print(f"Saved page.html ({len(res.content)} bytes)")
