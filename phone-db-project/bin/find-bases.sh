#!/bin/sh
set -eu

ROOT="${PHONE_DB_ROOT:-/root/phone-db-project}"
OUT_DIR="$ROOT/out"
mkdir -p "$OUT_DIR"

STAMP=$(date +%Y%m%d-%H%M%S)
OUT="$OUT_DIR/bases-$STAMP.txt"

find / \
  \( -name '*.db' -o -name '*.sqlite' -o -name '*.sqlite3' -o \
     -name '*.sql' -o -name '*.csv' -o -name '*.xlsx' -o -name '*.xls' \) \
  -type f 2>/dev/null > "$OUT" || true

ln -sfn "bases-$STAMP.txt" "$OUT_DIR/latest.txt"
wc -l < "$OUT"
