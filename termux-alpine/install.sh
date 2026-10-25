#!/data/data/com.termux/files/usr/bin/bash
# Установка Alpine Linux в Termux без root и без перепрошивки
set -e
pkg update -y
pkg install -y proot-distro
proot-distro install alpine
echo "Готово. Вход в Alpine: proot-distro login alpine"
proot-distro login alpine
