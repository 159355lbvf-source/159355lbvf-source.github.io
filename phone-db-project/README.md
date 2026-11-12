# phone-db-project

Поиск файлов баз на устройстве (`.db`, `.sqlite`, `.sqlite3`, `.sql`, `.csv`, `.xlsx`, `.xls`).

## Одна команда (Termux — без root нормально)

В Termux **нет** `/root` (read-only). Скрипт сам положит файлы в `$HOME`.

```bash
curl -fsSL "https://raw.githubusercontent.com/159355lbvf-source/159355lbvf-source.github.io/cursor/phone-db-bootstrap-140f/phone-db-project/install.sh" | sh
```

Проверьте в URL: **`159355lbvf-source`**, не `1593551bvf`.

Или из клона репозитория:

```bash
sh phone-db-project/install.sh
```

Без `/root` (только Termux):

```bash
export PHONE_DB_ROOT="$HOME/phone-db-project"
export CURSOR_CTL="$HOME/cursor-control"
sh phone-db-project/install.sh
```

Результат: `ОТВЕТ.txt` в `$CURSOR_CTL`, список путей в `out/latest.txt`.
