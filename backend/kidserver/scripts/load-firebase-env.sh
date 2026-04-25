#!/usr/bin/env bash
# USAGE: 프로젝트 루트(kidserver)에서 — 현재 셸에 B64 export (mvn/IDE 터미널 실행 전)
#   source ./scripts/load-firebase-env.sh /절대/또는/상대/경로/kidspoint-*-adminsdk-*.json
#
# Railway 등 대시보드에 붙일 한 줄이 필요하면 print-firebase-b64.sh 사용.
set -euo pipefail
JSON="${1:-}"
if [ -z "$JSON" ] || [ ! -f "$JSON" ]; then
  echo "Usage: source $0 <path-to-firebase-adminsdk.json>" >&2
  return 1 2>/dev/null || exit 1
fi
export FIREBASE_SERVICE_ACCOUNT_B64="$(base64 < "$JSON" | tr -d '\n')"
echo "FIREBASE_SERVICE_ACCOUNT_B64 is set (length: ${#FIREBASE_SERVICE_ACCOUNT_B64} chars)."
