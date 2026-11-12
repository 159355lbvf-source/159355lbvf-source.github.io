#!/bin/sh
# Запускать только на телефоне (my-phone / Alpine в Termux)
set -e

ROOT="${PHONE_DB_ROOT:-/root}"
PROJECT="$ROOT/phone-db-project"
CONTROL="$ROOT/cursor-control"

mkdir -p "$PROJECT"/{bin,out,data} "$CONTROL"

cat > "$PROJECT/README.txt" <<'EOF'
phone-db-project — проект на телефоне.
Задания: /root/cursor-control/ЗАДАНИЕ.txt
Ответы:  /root/cursor-control/ОТВЕТ.txt
Поиск баз: /root/phone-db-project/bin/find-bases.sh
EOF

cat > "$PROJECT/bin/find-bases.sh" <<'EOF'
#!/bin/sh
OUT="/root/phone-db-project/out/СПИСОК-БАЗ.txt"
DATE="$(date +%Y-%m-%d)"
{
  echo "Дата: $DATE"
  echo "---"
  find /data /storage /sdcard /root /home "$HOME" 2>/dev/null \
    -type f \( \
      -iname '*.db' -o -iname '*.sqlite' -o -iname '*.sqlite3' \
      -o -iname '*.sql' -o -iname '*.csv' \
      -o -iname '*.xlsx' -o -iname '*.xls' \
      -o -iname '*.mdb' -o -iname '*.ods' -o -iname '*.dbf' \
    \)
} | tee "$OUT"
echo "Записано: $OUT ($(grep -vc '^---\|^Дата:' "$OUT" || true) файлов)"
EOF
chmod +x "$PROJECT/bin/find-bases.sh"

for f in ЗАДАНИЕ.txt ОТВЕТ.txt README.txt; do
  [ -f "$CONTROL/$f" ] || touch "$CONTROL/$f"
done

if [ ! -s "$CONTROL/ЗАДАНИЕ.txt" ]; then
  echo "новый проект: выполни find-bases.sh и краткий отчёт в ОТВЕТ.txt" > "$CONTROL/ЗАДАНИЕ.txt"
fi

{
  echo "Дата: $(date +%Y-%m-%d)"
  echo "Статус: проект phone-db-project создан"
  echo "Каталог: $PROJECT"
  echo "Следующий шаг: $PROJECT/bin/find-bases.sh"
} > "$CONTROL/ОТВЕТ.txt"

echo "OK: $PROJECT"
