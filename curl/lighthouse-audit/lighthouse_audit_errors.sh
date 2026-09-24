#!/usr/bin/env bash
set -euo pipefail

response=$(mktemp)
headers=$(mktemp)
trap 'rm -f "$response" "$headers"' EXIT

# urlpipe PATH JSON: POST a sync request, leaving the result in $response.
# Retries the two 429s that clear by themselves; fails with a message otherwise.
urlpipe() {
  local attempt status code detail retry_after
  for attempt in 0 1 2 3 4; do
    status=$(curl -sS --max-time 90 -o "$response" -D "$headers" -w '%{http_code}' \
      "https://urlpipe.dev$1" \
      -H "Authorization: Bearer $URLPIPE_API_KEY" \
      -H "Content-Type: application/json" \
      -d "$2")
    case "$status" in
      200) return 0 ;;
      401) echo "URLpipe: 401: the API key is missing or wrong. Check URLPIPE_API_KEY." >&2; return 1 ;;
    esac

    # A body that is not JSON leaves both empty.
    code=$(jq -r '.error // ""' "$response" 2>/dev/null || true)
    detail=$(jq -r 'if .message then "\(.error): \(.message)" else .error end' "$response" 2>/dev/null || true)

    if [ "$status" = 429 ] && [ "$code" = rate_limited ]; then
      # Sending too fast: Retry-After says how long the window has left.
      retry_after=$(awk 'tolower($1) == "retry-after:" { print $2 + 0 }' "$headers")
      sleep "${retry_after:-1}"
    elif [ "$status" = 429 ] && [ "$code" = concurrency_limit ]; then
      # Every parallel slot on your plan is busy with your own requests.
      sleep $((2 ** attempt))
    elif [ "$status" = 504 ]; then
      # Still running on our side; the token collects it from GET /result/:token.
      echo "URLpipe: 504 processing_timeout: collect it later with token $(jq -r .token "$response")" >&2
      return 1
    else
      # 403 email_unverified, 422 (a bad parameter, or a page that would not load),
      # 429 quota_exceeded: sending the same request again gets the same answer.
      echo "URLpipe: $status: $detail" >&2
      return 1
    fi
  done
  echo "URLpipe: 429: still refused after 5 attempts" >&2
  return 1
}

urlpipe /lighthouse '{"url": "https://example.com", "device": "mobile", "sync": true}' || exit 1

jq -r '
  (["performance", "accessibility", "best-practices", "seo"][] as $name
    | "\($name): \(.categories[$name].score | if . == null then "n/a" else . * 100 | round end)"),
  "LCP: \(.metrics["largest-contentful-paint"].displayValue // "n/a")",
  "CLS: \(.metrics["cumulative-layout-shift"].displayValue // "n/a")",
  "TBT: \(.metrics["total-blocking-time"].displayValue // "n/a")"
' "$response"
