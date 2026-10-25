# Alpine Linux на Android (Termux + proot-distro)

1. Установите F-Droid: https://f-droid.org
2. В F-Droid найдите и установите **Termux** (версия из Google Play устарела).
3. Откройте Termux и вставьте одну команду:

```
pkg update -y && pkg install -y proot-distro && proot-distro install alpine && proot-distro login alpine
```

4. Повторный вход: `proot-distro login alpine`. Выход: `exit`.
5. Удаление: `proot-distro remove alpine`.

Место: сам Alpine занимает около 10–20 МБ, Termux с proot-distro около 100–150 МБ. Итого примерно 150 МБ.
Установка пакетов внутри Alpine: `apk add имя_пакета`.
