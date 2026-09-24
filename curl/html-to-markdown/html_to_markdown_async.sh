#!/usr/bin/env bash
set -euo pipefail

response=$(mktemp)
trap 'rm -f "$response"' EXIT

API=https://urlpipe.dev
AUTH="Authorization: Bearer $URLPIPE_API_KEY"

# No "sync": the request is accepted at once and the work carries on without you.
status=$(curl -sS -o "$response" -w '%{http_code}' "$API/markdown" \
  -H "$AUTH" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com",
    "report_to": "https://your-app.com/webhooks/urlpipe",
    "labels": {"customer": "acme"}
  }')
if [ "$status" != 200 ]; then
  echo "URLpipe answered $status: $(cat "$response")" >&2
  exit 1
fi
token=$(jq -r .token "$response")
echo "Accepted $token"

# The result is POSTed to report_to when it is ready. Polling by token is the
# other way to collect it: no endpoint needed, and a backup for the webhook.
for _ in $(seq 60); do
  status=$(curl -sS -o "$response" -w '%{http_code}' "$API/result/$token" -H "$AUTH")
  [ "$status" = 202 ] || break # 202 means still processing
  sleep 2
done

case "$status" in
  200) ;;
  202) echo "Still processing after two minutes; try the token again later." >&2; exit 1 ;;
  422) echo "The analysis failed: $(jq -r .error "$response")" >&2; exit 1 ;;
  410) echo "The result is past the 30-day window; send the request again." >&2; exit 1 ;;
  *) echo "URLpipe answered $status: $(cat "$response")" >&2; exit 1 ;;
esac

# Plain text: pipe it into a file, a chunker or a prompt.
cat "$response"
echo
