# PocketClaw + Cursor

Связка **Cursor на ПК** с **агентом OpenClaw на телефоне** (PocketClaw) через MCP.

На скриншоте приложения видно конечную точку вроде `http://26.26.26.1:18800` (часто это Radmin VPN или «общий режим»). Дашборд и **Gateway API** могут слушать **разные порты** — ниже, как их согласовать.

## Два разных «MCP PocketClaw»

| Вариант | Зачем |
| -------- | ----- |
| `https://pocketclaw.dev/api/mcp` | Публичная база CVE по self-hosted AI. **Не** управляет вашим телефоном. |
| `openclaw-cli mcp` на ПК | Чат и инструменты **вашего** Gateway на телефоне. **Это нужно вам.** |

## Схема

```
Cursor (ПК)  --stdio MCP-->  openclaw-cli mcp  --HTTP-->  OpenClaw Gateway (телефон)
                                    ↑
                         VPN / LAN (например 26.26.26.1)
```

Telegram и облачный AI с телефона работают как раньше; Cursor становится ещё одним клиентом к тому же Gateway.

## 1. Сеть: чтобы ПК видел телефон

1. Оставьте PocketClaw **АКТИВЕН** и тот же VPN, что на скриншоте (у вас `26.26.26.1`).
2. На **ПК**, подключённом к той же VPN, проверьте дашборд:

```bash
curl -sS -m 5 "http://26.26.26.1:18800/api/status" | head -c 400
```

Если порт у вас другой (в документации PocketClaw часто `9000`), подставьте свой URL из приложения.

3. Запомните IP и порты. Для MCP обычно нужен **Gateway HTTP**, по умолчанию порт **18789** (не обязательно тот же, что «Веб-админ» в приложении).

Проверка Gateway (подставьте IP и порт):

```bash
curl -sS -m 5 -o /dev/null -w "%{http_code}\n" "http://26.26.26.1:18789/"
```

Код `401`, `404` или ответ JSON часто значит, что хост доступен. Таймаут — смотрите firewall, bind Gateway и VPN.

## 2. На телефоне: открыть API для Cursor

### 2.1 Токен Gateway

Токен обычно лежит в `~/.openclaw/openclaw.json` (внутри Termux/proot) в `gateway.auth.token`, либо на вкладке **KEYS** веб-дашборда. Скопируйте его на ПК — в чат и GitHub **не** выкладывайте.

### 2.2 Включить OpenResponses (обязательно для `openclaw-cli`)

В `openclaw.json` на телефоне:

```json5
{
  "gateway": {
    "http": {
      "endpoints": {
        "responses": { "enabled": true }
      }
    }
  }
}
```

Перезапустите gateway: в PocketClaw **CTRL** / `pocketclaw restart`, или из Termux по инструкции вашей сборки.

### 2.3 Доступ с VPN/LAN (не с публичного интернета)

По умолчанию Gateway слушает loopback. С ПК через VPN нужен bind на LAN/VPN **с токеном**:

```json5
{
  "gateway": {
    "bind": "lan",
    "auth": {
      "mode": "token",
      "token": "ВАШ_ДОЛГИЙ_СЕКРЕТ"
    },
    "port": 18789
  }
}
```

Документация OpenClaw: [Remote access](https://docs.openclaw.ai/gateway/remote). Не открывайте порт в интернет без Tailscale/SSH; Radmin — только для доверенных устройств.

Если в приложении указан только `:18800`, в **LOGS** или `openclaw.json` уточните фактический `gateway.port` и проброс в «общем режиме».

## 3. На ПК: `openclaw-cli`

Нужны Node.js 18+ и curl.

```bash
curl -fsSL https://raw.githubusercontent.com/TimoBechtel/openclaw-cli/main/install.sh | bash
```

Проверка до настройки Cursor:

```bash
export OPENCLAW_BASE_URL="http://26.26.26.1:18789"
export OPENCLAW_GATEWAY_TOKEN="ваш-токен"
openclaw-cli ask "Ответь одним словом: связь есть?" --json
```

Успешный JSON с `response` — можно подключать MCP.

## 4. Cursor: `mcp.json`

Глобально: `~/.cursor/mcp.json` (Windows: `%USERPROFILE%\.cursor\mcp.json`).

Скопируйте [mcp.json.example](./mcp.json.example), подставьте URL и токен.

В Cursor: **Settings → MCP** — сервер `openclaw-phone` должен стать зелёным. В чате: «через OpenClaw на телефоне: какой статус gateway?».

## 5. Безопасность

- Токен Gateway = полный доступ к агенту: храните только локально в `mcp.json`.
- Дашборд PocketClaw без `POCKETCLAW_TOKEN` на LAN может быть открыт — задайте токен в env, если сеть не только ваша.
- Публичный MCP на pocketclaw.dev — только чтение CVE, не замена шагов выше.

## 6. Частые проблемы

| Симптом | Что сделать |
| -------- | ------------ |
| MCP красный в Cursor | Путь к `openclaw-cli` в PATH; перезапуск Cursor; валидный JSON в `mcp.json`. |
| `openclaw-cli ask` — таймаут | VPN, `gateway.bind`, порт, firewall на телефоне. |
| 401 Unauthorized | `OPENCLAW_GATEWAY_TOKEN` совпадает с `gateway.auth.token`. |
| Дашборд открывается, MCP нет | Админка ≠ Gateway: проверьте **18789** (или ваш `gateway.port`). |
| Нужны инструменты OpenClaw внутри Cursor IDE | Опционально: плагин [openclaw-cursor-brain](https://github.com/andeya/openclaw-cursor-brain) на Gateway (сложнее, нужен Node на стороне gateway). |

## 7. Дальше

- [OpenClaw remote](https://docs.openclaw.ai/gateway/remote) — SSH/Tailscale вместо Radmin.
- [PocketClaw](https://github.com/pocketclaw/pocketclaw) — дашборд, CLI на телефоне.
- [Alpine в Termux](../termux-alpine/README.md) — если ставите окружение с нуля.
