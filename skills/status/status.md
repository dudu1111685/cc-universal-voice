---
name: status
description: Check if the voice STT server is running
user_invocable: true
---

Check the status of the cc-universal-voice STT server.

Run this command:
```bash
PLUGIN_DATA="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugins/data/cc-universal-voice}"
PIDFILE="${PLUGIN_DATA}/voice_server.pid"
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  echo "Voice STT server is RUNNING (PID $(cat "$PIDFILE"))"
  echo "Log: ${PLUGIN_DATA}/voice_server.log"
  tail -5 "${PLUGIN_DATA}/voice_server.log" 2>/dev/null
else
  echo "Voice STT server is NOT running"
  echo "Run /cc-universal-voice:start to start it"
fi
```
