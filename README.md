# cc-universal-voice

Streaming speech-to-text plugin for Claude Code `/voice` — 60+ languages including Hebrew, powered by [Soniox](https://soniox.com).

## Install

Inside Claude Code, run:

```
/plugin marketplace add dudu1111685/cc-universal-voice
/plugin install cc-universal-voice@cc-universal-voice
```

Then go to `/plugin` → `cc-universal-voice` → `Configure options` → enter your Soniox API key.

Get a free API key (with $200 credit) at [console.soniox.com](https://console.soniox.com). After the free credit, it costs about **$1 per 10 hours** of voice usage.

Restart Claude Code for the voice server to start. Then use `/voice` as normal.

## How it works

When you start a Claude Code session, the plugin automatically:
1. Installs Python dependencies (first time only)
2. Starts a local WebSocket voice server on port 19876
3. Injects `VOICE_STREAM_BASE_URL` so `/voice` uses our server

Then just use `/voice` as normal — speak in any of 60+ languages and get real-time streaming transcription.

## Features

- **Real-time streaming** — partial results in <200ms (no "No speech detected")
- **60+ languages** — Hebrew, English, Spanish, French, German, Japanese, Korean, Chinese, Arabic, and many more
- **Best Hebrew accuracy** — 7.5% WER (2x better than Whisper)
- **Auto language detection** — speak any language without switching settings
- **Fallback mode** — works without API key using Anthropic proxy + Vosk

## Commands

| Command | Description |
|---------|-------------|
| `/cc-universal-voice:start` | Manually start the voice server |
| `/cc-universal-voice:stop` | Stop the voice server |
| `/cc-universal-voice:status` | Check if the server is running |

## Requirements

- Python 3.10+
- Claude Code v1.0.33+
- Soniox API key (optional, falls back to Anthropic proxy without it)

## Troubleshooting

**"No speech detected"**: Run `/cc-universal-voice:start` to manually start the server.

**Check logs**: `cat ~/.claude/plugins/data/cc-universal-voice/voice_server.log`

**Server not starting**: Ensure Python 3.10+ is installed: `python3 --version`
