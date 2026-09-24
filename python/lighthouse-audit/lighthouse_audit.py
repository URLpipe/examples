import os

import requests

res = requests.post(
    "https://urlpipe.dev/lighthouse",
    headers={"Authorization": f"Bearer {os.environ['URLPIPE_API_KEY']}"},
    json={"url": "https://example.com", "device": "mobile", "sync": True},
    # requests waits forever unless told otherwise; a sync call can take up to 60 s.
    timeout=90,
)
res.raise_for_status()

report = res.json()
for name in ("performance", "accessibility", "best-practices", "seo"):
    score = (report["categories"].get(name) or {}).get("score")
    print(f"{name}: {'n/a' if score is None else round(score * 100)}")

metrics = {
    "LCP": "largest-contentful-paint",
    "CLS": "cumulative-layout-shift",
    "TBT": "total-blocking-time",
}
for label, key in metrics.items():
    print(f"{label}: {(report['metrics'].get(key) or {}).get('displayValue', 'n/a')}")
