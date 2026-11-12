# Cursor My Machines на вашем сервере

Облако Cursor планирует задачи; **на сервере** выполняются команды, правки файлов, доступ к локальной БД и бэкапам. С телефона вы только отправляете задачи в [cursor.com/agents](https://cursor.com/agents) (или приложение Cursor).

## Что нужно один раз на сервере

1. Исходящий HTTPS (см. [доку](https://cursor.com/docs/cloud-agent/self-hosted/my-machines#networking)).
2. Git-репозитории приложения там, где они реально лежат (`--worker-dir`).
3. Локальные credentials БД (dashboard secrets на My Machines **не** подставляются).

## Быстрая установка

С телефона через SSH (Termius, ConnectBot и т.п.):

```bash
curl -fsSL https://raw.githubusercontent.com/159355lbvf-source/159355lbvf-source.github.io/main/cursor-my-machine/install-worker.sh -o install-worker.sh
chmod +x install-worker.sh
agent login   # откроется ссылка — войдите в тот же аккаунт, что на телефоне
```

С именем машины и путями к проектам:

```bash
export WORKER_NAME="my-server"
export WORKER_DIRS="/path/to/your/app,/path/to/ParserTG"
./install-worker.sh
```

Без браузера на сервере (API key из **Cursor Dashboard → API Keys**, именно **user**, не service account):

```bash
export CURSOR_API_KEY="ваш-user-api-key"
export WORKER_NAME="my-server"
export WORKER_DIRS="/path/to/your/app"
./install-worker.sh
```

После установки с systemd:

```bash
sudo systemctl status cursor-agent-worker
sudo journalctl -u cursor-agent-worker -f
```

## Управление с телефона

1. Откройте [cursor.com/agents](https://cursor.com/agents) или приложение Cursor.
2. Меню среды выполнения → **My Machines** → `my-server` (или ваш `WORKER_NAME`).
3. Пишите задачи: «сделай дамп Postgres», «восстанови из backup.sql», «перезапусти systemd-сервис X».

Из Slack / GitHub / Linear (если настроено):

```text
@cursoragent worker=my-server сделай pg_dump ...
```

Имя `worker=` должно совпадать с `--name`, а git remote в `--worker-dir` — с репозиторием триггера.

## Termux + Alpine

Если «сервер» — это Alpine в Termux (`termux-alpine/`), поставьте в Alpine: `curl`, `bash`, `tmux`, затем тот же `install-worker.sh` с `INSTALL_SYSTEMD=0`. Держите сессию: `tmux attach -t cursor-worker`.

## Проверка

На сервере:

```bash
agent worker debug
```

В облаке: машина появляется в picker только пока процесс `agent worker` запущен.

## Ссылки

- [My Machines](https://cursor.com/docs/cloud-agent/self-hosted/my-machines)
- [Team Pools (Enterprise)](https://cursor.com/docs/cloud-agent/self-hosted/pool)
