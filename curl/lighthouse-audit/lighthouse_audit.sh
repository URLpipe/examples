#!/usr/bin/env bash
set -euo pipefail

response=$(mktemp)
trap 'rm -f "$response"' EXIT

# -w prints the status; -o keeps the body out of the way until the status is known.
status=$(curl -sS --max-time 90 -o "$response" -w '%{http_code}' \
  https://urlpipe.dev/lighthouse \
  -H "Authorization: Bearer $URLPIPE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com", "device": "mobile", "sync": true}')

if [ "$status" != 200 ]; then
  echo "URLpipe answered $status: $(cat "$response")" >&2
  exit 1
fi

jq -r '
  (["performance", "accessibility", "best-practices", "seo"][] as $name
    | "\($name): \(.categories[$name].score | if . == null then "n/a" else . * 100 | round end)"),
  "LCP: \(.metrics["largest-contentful-paint"].displayValue // "n/a")",
  "CLS: \(.metrics["cumulative-layout-shift"].displayValue // "n/a")",
  "TBT: \(.metrics["total-blocking-time"].displayValue // "n/a")"
' "$response"
