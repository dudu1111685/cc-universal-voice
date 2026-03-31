---
name: start
description: Manually start the voice STT server (use if auto-start didn't work)
user_invocable: true
---

Start the cc-universal-voice STT server manually. Run this if `/voice` shows "No speech detected" after a fresh install.

Run this command:
```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/session-start.sh
```

After it completes, try `/voice` again.
