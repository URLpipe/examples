#!/usr/bin/env bash
set -euo pipefail

response=$(mktemp)
trap 'rm -f "$response"' EXIT

# -w prints the status; -o keeps the body out of the way until the status is known.
status=$(curl -sS --max-time 90 -o "$response" -w '%{http_code}' \
  https://urlpipe.dev/screenshot \
  -H "Authorization: Bearer $URLPIPE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com", "page_options": {"block_cookie_banners": true}, "sync": true}')

if [ "$status" != 200 ]; then
  echo "URLpipe answered $status: $(cat "$response")" >&2
  exit 1
fi

base64 --decode < "$response" > screenshot.png
echo "Saved screenshot.png ($(wc -c < screenshot.png | tr -d ' ') bytes)"
