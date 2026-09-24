#!/usr/bin/env bash
# Usage: ./check_signature.sh TIMESTAMP 'SIGNATURE_HEADER' body.json
# For debugging only: bash compares strings in variable time.
set -euo pipefail

timestamp=$1
header=$2
body_file=$3

digest=$({ printf '%s.' "$timestamp"; cat "$body_file"; } \
  | openssl dgst -sha256 -hmac "$URLPIPE_WEBHOOK_SECRET" | sed 's/^.*= //')
expected="v1=$digest"
age=$(( $(date +%s) - timestamp ))

IFS=',' read -ra signatures <<< "$header"
for signature in "${signatures[@]}"; do
  if [ "${signature// /}" = "$expected" ]; then
    echo "Valid signature, signed ${age#-} seconds ago"
    if [ "${age#-}" -gt 300 ]; then
      echo "Older than five minutes: a receiver with a 5-minute tolerance rejects it" >&2
      exit 1
    fi
    exit 0
  fi
done
echo "No signature matches: expected $expected" >&2
exit 1
