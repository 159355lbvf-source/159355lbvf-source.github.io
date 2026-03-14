# Безопасный контур для 20 агентов (Telegram)

Этот набор нужен для оркестрации нескольких репозиториев/агентов **одной командой** и подготовки задач для Telegram-аккаунтов.

## Принципы

- Только для контактов с согласием (`consent=true`).
- Без авто-рассылки в коде: создаются только задания и черновики.
- Дневные лимиты по каждому аккаунту.

## Структура

- `config/repos.example.txt` — список путей к репозиториям агентов.
- `config/accounts.example.csv` — аккаунты и дневные лимиты.
- `config/contacts.example.csv` — пример базы контактов с согласием.
- `tools/fanout_command.py` — запуск одной команды во всех репозиториях.
- `tools/plan_daily_contacts.py` — распределение контактов по аккаунтам.
- `tools/render_message_drafts.py` — генерация черновиков сообщений по шаблону.
- `templates/default_message.txt` — шаблон текста.

## Быстрый старт

1. Скопируй примеры конфигов:
   - `repos.example.txt` -> `repos.txt`
   - `accounts.example.csv` -> `accounts.csv`
   - `contacts.example.csv` -> `contacts.csv`
2. Запусти команду во всех репозиториях:
   - `python3 tools/fanout_command.py --repos config/repos.txt --command "git status --short"`
3. Сформируй дневной план контактов:
   - `python3 tools/plan_daily_contacts.py --accounts config/accounts.csv --contacts config/contacts.csv --out out/assignments.csv`
4. Сгенерируй черновики для ручной отправки:
   - `python3 tools/render_message_drafts.py --assignments out/assignments.csv --template templates/default_message.txt --out-dir out/drafts`

