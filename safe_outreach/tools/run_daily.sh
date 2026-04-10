#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_DATE="${1:-$(date +%F)}"
COOLDOWN_DAYS="${COOLDOWN_DAYS:-2}"
JOBS="${JOBS:-20}"
CHECK_COMMAND="${CHECK_COMMAND:-git status --short}"

REPOS_FILE="${BASE_DIR}/config/repos.txt"
ACCOUNTS_FILE="${BASE_DIR}/config/accounts.csv"
CONTACTS_FILE="${BASE_DIR}/config/contacts.csv"
TEMPLATE_FILE="${BASE_DIR}/templates/default_message.txt"
ASSIGNMENTS_OUT="${BASE_DIR}/out/assignments.csv"
DRAFTS_OUT_DIR="${BASE_DIR}/out/drafts"

if [[ ! -f "${REPOS_FILE}" ]]; then
  echo "Не найден ${REPOS_FILE}"
  exit 1
fi

if [[ ! -f "${ACCOUNTS_FILE}" ]]; then
  echo "Не найден ${ACCOUNTS_FILE}"
  exit 1
fi

if [[ ! -f "${CONTACTS_FILE}" ]]; then
  echo "Не найден ${CONTACTS_FILE}"
  exit 1
fi

echo "[1/3] Проверяю состояние всех репозиториев..."
python3 "${BASE_DIR}/tools/fanout_command.py" \
  --repos "${REPOS_FILE}" \
  --command "${CHECK_COMMAND}" \
  --jobs "${JOBS}"

echo
echo "[2/3] Формирую план контактов на ${RUN_DATE}..."
python3 "${BASE_DIR}/tools/plan_daily_contacts.py" \
  --accounts "${ACCOUNTS_FILE}" \
  --contacts "${CONTACTS_FILE}" \
  --out "${ASSIGNMENTS_OUT}" \
  --date "${RUN_DATE}" \
  --cooldown-days "${COOLDOWN_DAYS}"

echo
echo "[3/3] Генерирую черновики для ручной отправки..."
python3 "${BASE_DIR}/tools/render_message_drafts.py" \
  --assignments "${ASSIGNMENTS_OUT}" \
  --template "${TEMPLATE_FILE}" \
  --out-dir "${DRAFTS_OUT_DIR}"

echo
echo "Готово."
echo "План: ${ASSIGNMENTS_OUT}"
echo "Черновики: ${DRAFTS_OUT_DIR}"

