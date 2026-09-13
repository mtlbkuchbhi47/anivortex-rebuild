#!/usr/bin/env bash
set -euo pipefail
APK="${1:-anivortex_5.0.1.apk}"
OUT="${2:-runtime-evidence.txt}"
unzip -p "$APK" lib/arm64-v8a/libapp.so > /tmp/anivortex-libapp.so
strings /tmp/anivortex-libapp.so | grep -E 'api\.anivortex|bootstrap|api_routes|stream_id|episode_number|poster_url|backdrop_url|download|GoogleSignIn|Firebase|SearchContentType' | sort -u > "$OUT"
echo "Wrote $OUT"
