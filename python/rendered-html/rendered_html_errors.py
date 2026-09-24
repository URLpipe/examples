import os
import sys
import time

import requests

API_KEY = os.environ["URLPIPE_API_KEY"]


class URLpipeError(Exception):
    pass


def urlpipe(path, payload, attempts=5):
    """POST a sync request and return the response, or raise URLpipeError."""
    for attempt in range(attempts):
        res = requests.post(
            f"https://urlpipe.dev{path}",
            headers={"Authorization": f"Bearer {API_KEY}"},
            json={**payload, "sync": True},
            timeout=90,
        )
        if res.status_code == 200:
            return res
        if res.status_code == 401:
            raise URLpipeError("401: the API key is missing or wrong. Check URLPIPE_API_KEY.")

        try:
            body = res.json()
        except ValueError:
            body = {}
        code = body.get("error", "")
        detail = f"{code}: {body['message']}" if body.get("message") else code

        if res.status_code == 429 and code == "rate_limited":
            # Sending too fast: Retry-After says how long the window has left.
            time.sleep(int(res.headers.get("Retry-After", 1)))
        elif res.status_code == 429 and code == "concurrency_limit":
            # Every parallel slot on your plan is busy with your own requests.
            time.sleep(2**attempt)
        elif res.status_code == 504:
            # Still running on our side; the token collects it from GET /result/:token.
            raise URLpipeError(f"504 processing_timeout: collect it later with token {body['token']}")
        else:
            # 403 email_unverified, 422 (a bad parameter, or a page that would not load),
            # 429 quota_exceeded: sending the same request again gets the same answer.
            raise URLpipeError(f"{res.status_code}: {detail}")
    raise URLpipeError(f"429: still refused after {attempts} attempts")


try:
    res = urlpipe("/html", {"url": "https://example.com"})
except URLpipeError as error:
    sys.exit(f"URLpipe: {error}")
except requests.RequestException as error:
    sys.exit(f"Network error: {error}")

with open("page.html", "wb") as f:
    f.write(res.content)
print(f"Saved page.html ({len(res.content)} bytes)")
