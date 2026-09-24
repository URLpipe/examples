#!/usr/bin/env bash
# Usage: ./send_signed_delivery.sh [endpoint]
set -euo pipefail

endpoint=${1:-http://localhost:8000/webhooks/urlpipe}
body='{"token":"test_token","operation":"markdown","labels":{},"success":true,"result":"# Example Domain","result_url":null,"error":null,"meta":{}}'
timestamp=$(date +%s)
signature=$(printf '%s.%s' "$timestamp" "$body" \
  | openssl dgst -sha256 -hmac "$URLPIPE_WEBHOOK_SECRET" | sed 's/^.*= //')

curl -sS -o /dev/null -w 'Your endpoint answered %{http_code}\n' "$endpoint" \
  -H "Content-Type: application/json" \
  -H "X-URLpipe-Timestamp: $timestamp" \
  -H "X-URLpipe-Signature: v1=$signature" \
  --data-binary "$body"
