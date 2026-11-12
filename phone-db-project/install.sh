#!/bin/sh
# One-shot: bootstrap + find + ОТВЕТ.txt (Termux без root → $HOME, иначе /root)
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

_can_use_root() {
  _t="/root/.cursor-write-test-$$"
  mkdir -p /root 2>/dev/null && touch "$_t" 2>/dev/null && rm -f "$_t" 2>/dev/null
}

if [ -z "${PHONE_DB_ROOT:-}" ] || [ -z "${CURSOR_CTL:-}" ]; then
  if _can_use_root; then
    PHONE_DB_ROOT="${PHONE_DB_ROOT:-/root/phone-db-project}"
    CURSOR_CTL="${CURSOR_CTL:-/root/cursor-control}"
  else
    PHONE_DB_ROOT="${PHONE_DB_ROOT:-$HOME/phone-db-project}"
    CURSOR_CTL="${CURSOR_CTL:-$HOME/cursor-control}"
    echo "Termux/без root: каталоги в $HOME"
  fi
fi

mkdir -p "$CURSOR_CTL" "$PHONE_DB_ROOT/bin" "$PHONE_DB_ROOT/out" "$PHONE_DB_ROOT/data"
cp "$SCRIPT_DIR/bin/find-bases.sh" "$PHONE_DB_ROOT/bin/find-bases.sh"
chmod +x "$PHONE_DB_ROOT/bin/find-bases.sh"

if [ -d "$PHONE_DB_ROOT/.git" ]; then
  git -C "$PHONE_DB_ROOT" pull --ff-only 2>/dev/null || true
fi

export PHONE_DB_ROOT
COUNT=$("$PHONE_DB_ROOT/bin/find-bases.sh")

{
  echo "Дата: $(date)"
  echo ""
  echo "=== hostname ==="
  hostname
  echo ""
  echo "=== free -m ==="
  free -m
  echo ""
  echo "=== df -h ==="
  df -h
  echo ""
  echo "=== Найдено файлов: $COUNT ==="
  echo "Полный список: $PHONE_DB_ROOT/out/latest.txt"
} > "$CURSOR_CTL/ОТВЕТ.txt"

echo "Готово: $CURSOR_CTL/ОТВЕТ.txt"
cat "$CURSOR_CTL/ОТВЕТ.txt"
