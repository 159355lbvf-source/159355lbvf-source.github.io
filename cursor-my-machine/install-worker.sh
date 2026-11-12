#!/usr/bin/env bash
# Cursor My Machines worker — one-shot install (Linux / WSL / Alpine in proot).
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/159355lbvf-source/159355lbvf-source.github.io/main/cursor-my-machine/install-worker.sh | bash
# Or with options:
#   WORKER_NAME=my-vps WORKER_DIRS="/opt/app,/opt/ParserTG" bash install-worker.sh
set -euo pipefail

WORKER_NAME="${WORKER_NAME:-my-server}"
# Comma-separated absolute paths to git checkouts (optional; default: cwd)
WORKER_DIRS="${WORKER_DIRS:-}"
INSTALL_CURSOR_CLI="${INSTALL_CURSOR_CLI:-1}"
INSTALL_SYSTEMD="${INSTALL_SYSTEMD:-auto}"
CURSOR_USER="${CURSOR_USER:-${SUDO_USER:-$USER}}"
CURSOR_HOME="$(getent passwd "$CURSOR_USER" 2>/dev/null | cut -d: -f6 || true)"
[[ -z "$CURSOR_HOME" ]] && CURSOR_HOME="$HOME"

log() { printf '[cursor-worker] %s\n' "$*"; }
die() { log "ERROR: $*"; exit 1; }

if ! command -v curl >/dev/null 2>&1; then
  die "curl is required"
fi

if [[ "$INSTALL_CURSOR_CLI" == "1" ]]; then
  log "Installing Cursor CLI..."
  curl https://cursor.com/install -fsS | bash
  export PATH="${HOME}/.local/bin:${PATH}"
fi

if ! command -v agent >/dev/null 2>&1; then
  die "agent not in PATH after install (try: export PATH=\"\$HOME/.local/bin:\$PATH\")"
fi

agent --version

if ! agent whoami >/dev/null 2>&1; then
  log "Sign in required. Run interactively: agent login"
  log "Or set CURSOR_API_KEY (personal user API key from Cursor Dashboard → API Keys) and re-run."
  if [[ -z "${CURSOR_API_KEY:-}" ]]; then
    die "Not logged in and CURSOR_API_KEY unset"
  fi
fi

build_worker_dirs_args() {
  local args=()
  if [[ -n "$WORKER_DIRS" ]]; then
    IFS=',' read -ra paths <<< "$WORKER_DIRS"
    for p in "${paths[@]}"; do
      p="${p#"${p%%[![:space:]]*}"}"
      p="${p%"${p##*[![:space:]]}"}"
      [[ -z "$p" ]] && continue
      [[ -d "$p" ]] || die "worker dir does not exist: $p"
      args+=(--worker-dir "$p")
    done
  fi
  printf '%s\n' "${args[@]}"
}

mapfile -t DIR_ARGS < <(build_worker_dirs_args)

# systemd
want_systemd=0
if [[ "$INSTALL_SYSTEMD" == "auto" ]]; then
  command -v systemctl >/dev/null 2>&1 && [[ -d /run/systemd/system ]] && want_systemd=1
elif [[ "$INSTALL_SYSTEMD" == "1" ]]; then
  want_systemd=1
fi

if [[ "$want_systemd" == "1" ]]; then
  UNIT_PATH="/etc/systemd/system/cursor-agent-worker.service"
  ENV_FILE="/etc/cursor-agent-worker.env"
  log "Installing systemd unit (run as user: $CURSOR_USER)"

  sudo tee "$ENV_FILE" >/dev/null <<EOF
# Cursor My Machines worker
WORKER_NAME=${WORKER_NAME}
EOF
  if [[ -n "${CURSOR_API_KEY:-}" ]]; then
    echo "CURSOR_API_KEY=${CURSOR_API_KEY}" | sudo tee -a "$ENV_FILE" >/dev/null
  fi
  sudo chmod 600 "$ENV_FILE"

  WRAPPER="${CURSOR_HOME}/.local/bin/cursor-worker-wrapper.sh"
  mkdir -p "${CURSOR_HOME}/.local/bin"
  {
    printf '%s\n' '#!/usr/bin/env bash'
    printf '%s\n' 'set -euo pipefail'
    printf '%s\n' "set -a"
    printf '%s\n' "source ${ENV_FILE}"
    printf '%s\n' "set +a"
    printf '%s\n' "AGENT=${CURSOR_HOME}/.local/bin/agent"
    printf '%s\n' 'args=(worker start --name "$WORKER_NAME")'
    for ((i=0; i<${#DIR_ARGS[@]}; i+=2)); do
      printf '%s\n' "args+=(${DIR_ARGS[$i]@Q} ${DIR_ARGS[$((i+1))]@Q})"
    done
    printf '%s\n' '[[ -n "${CURSOR_API_KEY:-}" ]] && args+=(--api-key "$CURSOR_API_KEY")'
    printf '%s\n' 'exec "$AGENT" "${args[@]}"'
  } > "$WRAPPER"
  chmod +x "$WRAPPER"
  chown "$CURSOR_USER:" "$WRAPPER" 2>/dev/null || true

  sudo tee "$UNIT_PATH" >/dev/null <<EOF
[Unit]
Description=Cursor Cloud Agent worker (My Machines)
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=${CURSOR_USER}
WorkingDirectory=${CURSOR_HOME}
EnvironmentFile=${ENV_FILE}
Environment=HOME=${CURSOR_HOME}
Environment=PATH=${CURSOR_HOME}/.local/bin:/usr/local/bin:/usr/bin:/bin
ExecStart=${WRAPPER}
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable cursor-agent-worker.service
  sudo systemctl restart cursor-agent-worker.service
  log "Started: sudo systemctl status cursor-agent-worker"
  sudo systemctl --no-pager status cursor-agent-worker.service || true
else
  log "No systemd — starting worker in tmux session 'cursor-worker' (install tmux if missing)."
  if ! command -v tmux >/dev/null 2>&1; then
    log "Install tmux and run:"
    printf '  agent worker start --name "%s"' "$WORKER_NAME"
    for ((i=0; i<${#DIR_ARGS[@]}; i+=2)); do
      printf ' %s %q' "${DIR_ARGS[$i]}" "${DIR_ARGS[$((i+1))]}"
    done
    printf '\n'
    exit 0
  fi
  tmux kill-session -t cursor-worker 2>/dev/null || true
  CMD="agent worker start --name $(printf '%q' "$WORKER_NAME")"
  for ((i=0; i<${#DIR_ARGS[@]}; i+=2)); do
    CMD+=" ${DIR_ARGS[$i]} $(printf '%q' "${DIR_ARGS[$((i+1))]}")"
  done
  [[ -n "${CURSOR_API_KEY:-}" ]] && CMD+=" --api-key $(printf '%q' "$CURSOR_API_KEY")"
  tmux new-session -d -s cursor-worker "$CMD"
  log "Worker running in tmux. Attach: tmux attach -t cursor-worker"
fi

log "Preflight: agent worker debug"
agent worker debug || true
log "On phone: https://cursor.com/agents → Run on → My Machines → ${WORKER_NAME}"
