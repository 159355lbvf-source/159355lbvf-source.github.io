# Termux как «сервер» для Cursor (облако)

Телефон в домашнем Wi‑Fi (`192.168.x.x`) из облака Cursor **не виден**. Нужны **SSH в Termux** + **Tailscale** (проще всего).

## Быстрая установка на телефоне

В **Termux** (из F-Droid):

```bash
curl -fsSL https://raw.githubusercontent.com/159355lbvf-source/159355lbvf-source.github.io/main/termux-alpine/remote-server-setup.sh | bash
```

Если ссылки ещё нет в main — скопируй файл `remote-server-setup.sh` с GitHub вручную и запусти: `bash remote-server-setup.sh`

Дополнительно:

```bash
termux-setup-storage
```

Разреши доступ к файлам — появится `~/storage/downloads` и др.

## Tailscale

1. Установи **Tailscale** на Android (F-Droid или сайт tailscale.com).
2. Войди в аккаунт.
3. Запомни IP телефона **100.x.x.x** в приложении.

## Что прислать облачному агенту

Одна строка (подставь свой IP из Tailscale):

```
u0_a123@100.64.12.34:8022
```

Пользователь — вывод `whoami` в Termux (часто `u0_a…`), порт чаще **8022**, не 22.

## Загрузка файлов на телефон

**С компа** (в той же Tailscale-сети):

```bash
scp -P 8022 ./мойфайл.db u0_a123@100.64.12.34:~/work/uploads/
```

**В Downloads на телефоне** (после `termux-setup-storage`):

```bash
scp -P 8022 ./файл u0_a123@100.64.12.34:~/storage/downloads/
```

## Cursor на своём ПК (без Tailscale)

Если ПК и телефон в одном Wi‑Fi:

```bash
ssh -p 8022 $(whoami)@192.168.0.182
```

В Cursor: Remote SSH → этот хост.

## Автозапуск sshd после перезагрузки (по желанию)

```bash
pkg install termux-boot
mkdir -p ~/.termux/boot
echo '#!/data/data/com.termux/files/usr/bin/bash' > ~/.termux/boot/sshd
echo 'sshd' >> ~/.termux/boot/sshd
chmod +x ~/.termux/boot/sshd
```

Нужно разрешить Termux autostart в настройках Android.

## Python

После скрипта уже стоит `python`. Рабочая папка: `~/work/`.
