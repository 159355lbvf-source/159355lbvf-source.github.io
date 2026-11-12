# phone-db-project (только my-phone)

Локальный проект на телефоне: поиск баз и таблиц, связка с `/root/cursor-control`.

## Установка (на телефоне, в Alpine/Termux)

```bash
cd /root
mkdir -p phone-db-project
# скопируйте bootstrap-on-phone.sh сюда или: git pull в клоне репо
sh bootstrap-on-phone.sh
```

После установки:

- `/root/phone-db-project/` — проект
- `/root/cursor-control/ЗАДАНИЕ.txt` — задания агенту
- `/root/cursor-control/ОТВЕТ.txt` — ответы

## Команды

```bash
/root/phone-db-project/bin/find-bases.sh
```

Список путей: `/root/phone-db-project/out/СПИСОК-БАЗ.txt`
