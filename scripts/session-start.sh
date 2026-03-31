#!/bin/bash
set -e

# cc-universal-voice: SessionStart hook
# Installs Python deps, starts voice server daemon, injects env vars

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-.}"
PLUGIN_DATA="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugins/data/cc-universal-voice}"
VENV="${PLUGIN_DATA}/venv"
PIDFILE="${PLUGIN_DATA}/voice_server.pid"
LOGFILE="${PLUGIN_DATA}/voice_server.log"
PORT=19876

# ── 1. Find Python >= 3.10 ──────────────────────────────────
PYTHON=""
for py in python3.12 python3.11 python3.10 python3; do
  if command -v "$py" &>/dev/null; then
    ver=$("$py" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null || echo "0.0")
    major=$(echo "$ver" | cut -d. -f1)
    minor=$(echo "$ver" | cut -d. -f2)
    if [ "$major" -ge 3 ] && [ "$minor" -ge 10 ]; then
      PYTHON="$py"
      break
    fi
  fi
done

if [ -z "$PYTHON" ]; then
  echo "[cc-universal-voice] Python >= 3.10 required but not found" >&2
  exit 0  # Don't block session start
fi

# ── 2. Create/update venv + install deps ────────────────────
mkdir -p "$PLUGIN_DATA"

if ! diff -q "${PLUGIN_ROOT}/requirements.txt" "${PLUGIN_DATA}/requirements.txt" >/dev/null 2>&1; then
  if [ ! -d "$VENV" ]; then
    "$PYTHON" -m venv "$VENV" 2>/dev/null || {
      echo "[cc-universal-voice] Failed to create venv" >&2
      exit 0
    }
  fi
  "$VENV/bin/pip" install -q --upgrade pip 2>/dev/null || true
  "$VENV/bin/pip" install -q -r "${PLUGIN_ROOT}/requirements.txt" 2>/dev/null || {
    # Retry without vosk (may not have wheel for all platforms)
    "$VENV/bin/pip" install -q soniox websockets 2>/dev/null || {
      echo "[cc-universal-voice] Failed to install dependencies" >&2
      rm -f "${PLUGIN_DATA}/requirements.txt"
      exit 0
    }
  }
  cp "${PLUGIN_ROOT}/requirements.txt" "${PLUGIN_DATA}/requirements.txt"
fi

# ── 3. Check if daemon is already running ───────────────────
if [ -f "$PIDFILE" ]; then
  PID=$(cat "$PIDFILE" 2>/dev/null || echo "")
  if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
    # Daemon running — just inject env vars
    if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
      echo "VOICE_STREAM_BASE_URL=ws://127.0.0.1:${PORT}" >> "$CLAUDE_ENV_FILE"
      [ -n "${CLAUDE_PLUGIN_OPTION_SONIOX_API_KEY:-}" ] && \
        echo "SONIOX_API_KEY=${CLAUDE_PLUGIN_OPTION_SONIOX_API_KEY}" >> "$CLAUDE_ENV_FILE"
    fi
    exit 0
  fi
  rm -f "$PIDFILE"
fi

# ── 4. Start daemon ─────────────────────────────────────────
SONIOX_API_KEY="${CLAUDE_PLUGIN_OPTION_SONIOX_API_KEY:-}" \
  nohup "$VENV/bin/python" "${PLUGIN_ROOT}/scripts/voice_server.py" \
  > "$LOGFILE" 2>&1 &
DAEMON_PID=$!
echo "$DAEMON_PID" > "$PIDFILE"
disown "$DAEMON_PID" 2>/dev/null || true

# Brief wait to confirm startup
sleep 0.5
if ! kill -0 "$DAEMON_PID" 2>/dev/null; then
  echo "[cc-universal-voice] Daemon failed to start. Check $LOGFILE" >&2
  rm -f "$PIDFILE"
  exit 0
fi

# ── 5. Inject env vars into Claude Code session ─────────────
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "VOICE_STREAM_BASE_URL=ws://127.0.0.1:${PORT}" >> "$CLAUDE_ENV_FILE"
  [ -n "${CLAUDE_PLUGIN_OPTION_SONIOX_API_KEY:-}" ] && \
    echo "SONIOX_API_KEY=${CLAUDE_PLUGIN_OPTION_SONIOX_API_KEY}" >> "$CLAUDE_ENV_FILE"
fi

exit 0
