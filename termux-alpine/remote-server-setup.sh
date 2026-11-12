#!/data/data/com.termux/files/usr/bin/bash
# Termux: SSH + Python + место под файлы. После Tailscale облачный агент сможет подключаться.
set -euo pipefail

CLOUD_AGENT_PUBKEY='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDkXYYc74DtAVyrGqHUPeykWWw8f+3DPqZHT1sWYSTak cursor-cloud-agent'

echo "==> Обновление пакетов"
pkg update -y
pkg install -y openssh python git rsync curl

echo "==> SSH: ключ для облачного Cursor"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
touch "$HOME/.ssh/authorized_keys"
chmod 600 "$HOME/.ssh/authorized_keys"
if ! grep -qF "cursor-cloud-agent" "$HOME/.ssh/authorized_keys" 2>/dev/null; then
  echo "$CLOUD_AGENT_PUBKEY" >> "$HOME/.ssh/authorized_keys"
fi

SSHD_DIR="$PREFIX/etc/ssh"
mkdir -p "$SSHD_DIR"
if [[ ! -f "$SSHD_DIR/sshd_config" ]]; then
  sshd -f /dev/null 2>/dev/null || true
fi
if [[ -f "$SSHD_DIR/sshd_config" ]]; then
  grep -q '^PasswordAuthentication' "$SSHD_DIR/sshd_config" \
    || echo 'PasswordAuthentication no' >> "$SSHD_DIR/sshd_config"
fi

echo "==> Запуск sshd"
pkill -x sshd 2>/dev/null || true
sshd

WORKDIR="$HOME/work"
mkdir -p "$WORKDIR/uploads" "$WORKDIR/projects"
echo "$WORKDIR" > "$HOME/.remote_workdir"

PORT="$(grep -E '^Port' "$SSHD_DIR/sshd_config" 2>/dev/null | awk '{print $2}')"
PORT="${PORT:-8022}"

echo ""
echo "=== Готово (Termux) ==="
echo "Пользователь: $USER"
echo "Порт SSH:     $PORT (обычно 8022 в Termux)"
echo "Папка работы: $WORKDIR"
echo ""
echo "1) Разреши доступ к памяти телефона: выполни отдельно  termux-setup-storage"
echo "   (появится ~/storage/ — Downloads, DCIM и т.д.)"
echo ""
echo "2) Поставь Tailscale (F-Droid / Play), войди в аккаунт."
echo "   Скопируй IP вида 100.x.x.x из приложения."
echo ""
echo "3) Напиши агенту одной строкой:"
echo "   $USER@100.x.x.x:$PORT"
echo ""
echo "Проверка с телефона: ssh -p $PORT $USER@127.0.0.1"
