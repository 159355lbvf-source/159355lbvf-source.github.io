#!/usr/bin/env bash
# Быстрая проверка с ПК: дашборд PocketClaw и (опционально) OpenClaw Gateway.
set -euo pipefail

DASH_URL="${1:-http://26.26.26.1:18800}"
GW_URL="${2:-http://26.26.26.1:18789}"

echo "== Dashboard/API: $DASH_URL/api/status"
if curl -sS -m 8 -f "$DASH_URL/api/status" | head -c 300; then
  echo
  echo "(OK)"
else
  echo "(FAIL — проверьте VPN и порт из приложения PocketClaw)"
fi

echo
echo "== Gateway HTTP: $GW_URL"
code=$(curl -sS -m 8 -o /dev/null -w "%{http_code}" "$GW_URL/" || true)
echo "HTTP $code (401/404 часто нормально; 000 — нет маршрута до Gateway)"
