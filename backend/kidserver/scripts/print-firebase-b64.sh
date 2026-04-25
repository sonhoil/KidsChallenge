#!/usr/bin/env bash
# USAGE: Railway / 호스팅의 환경 변수 FIREBASE_SERVICE_ACCOUNT_B64에 넣을 값만 출력(한 줄, 개행 없음)
#   ./scripts/print-firebase-b64.sh /path/to/kidspoint-*-adminsdk-*.json
# macOS: ... | pbcopy  로 클립보드 복사
set -euo pipefail
JSON="${1:-}"
if [ -z "$JSON" ] || [ ! -f "$JSON" ]; then
  echo "Usage: $0 <path-to-firebase-adminsdk.json>" >&2
  exit 1
fi
base64 < "$JSON" | tr -d '\n'
