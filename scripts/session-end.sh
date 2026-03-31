#!/bin/bash
# cc-universal-voice: SessionEnd hook — stop daemon (must complete in <1500ms)

PLUGIN_DATA="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugins/data/cc-universal-voice}"
PIDFILE="${PLUGIN_DATA}/voice_server.pid"

if [ -f "$PIDFILE" ]; then
  PID=$(cat "$PIDFILE" 2>/dev/null || echo "")
  if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
    kill "$PID" 2>/dev/null || true
  fi
  rm -f "$PIDFILE"
fi
