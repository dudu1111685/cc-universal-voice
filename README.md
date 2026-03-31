<p align="center">
  <img src="https://raw.githubusercontent.com/dudu1111685/cc-universal-voice/main/assets/banner.svg" alt="cc-universal-voice" width="600" />
</p>

<h1 align="center">cc-universal-voice</h1>

<p align="center">
  <strong>Real-time streaming speech-to-text for Claude Code <code>/voice</code></strong><br>
  60+ languages &bull; Hebrew excellence &bull; <200ms latency &bull; auto language detection
</p>

<p align="center">
  <a href="https://github.com/dudu1111685/cc-universal-voice/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License" /></a>
  <a href="https://soniox.com"><img src="https://img.shields.io/badge/powered%20by-Soniox-orange.svg" alt="Soniox" /></a>
  <a href="#install"><img src="https://img.shields.io/badge/Claude%20Code-plugin-blueviolet.svg" alt="Claude Code Plugin" /></a>
</p>

---

Claude Code's built-in `/voice` supports ~20 languages through Anthropic's servers. **cc-universal-voice** replaces that with [Soniox](https://soniox.com) streaming STT — giving you **60+ languages**, **real-time partial results**, and the **best Hebrew accuracy available** (7.5% WER, 2x better than Whisper).

<p align="center">
  <img src="https://raw.githubusercontent.com/dudu1111685/cc-universal-voice/main/assets/demo.gif" alt="Demo" width="700" />
</p>

## Why?

| | Built-in `/voice` | cc-universal-voice |
|---|---|---|
| **Languages** | ~20 | **60+** |
| **Hebrew** | Not supported | **7.5% WER** (best available) |
| **Latency** | Varies | **<200ms** partial results |
| **Language switching** | Manual via `/config` | **Auto-detected** |
| **"No speech detected"** | Common for non-English | **Eliminated** |

## Install

Three steps inside Claude Code:

```
/plugin marketplace add dudu1111685/cc-universal-voice
```
```
/plugin install cc-universal-voice@cc-universal-voice
```

Then configure your API key:

> `/plugin` &rarr; `cc-universal-voice` &rarr; `Configure options` &rarr; paste your Soniox API key

Restart Claude Code. Done. Use `/voice` as normal.

### Get a Soniox API key

1. Go to [console.soniox.com](https://console.soniox.com)
2. Sign up (free — includes **$200 credit**)
3. Copy your API key

> After the free credit, it costs about **$1 per 10 hours** of voice usage.

## How it works

```
You speak
  |
  v
Claude Code (/voice) ---> WebSocket ---> cc-universal-voice server
                                              |
                                              v
                                         Soniox streaming API
                                              |
                                         partial results (<200ms)
                                              |
                                              v
Claude Code <--- "שלום, מה נשמע?" <--- real-time transcript
```

The plugin automatically:
1. **Installs** Python dependencies (first time only, ~30 seconds)
2. **Starts** a local voice server on session start
3. **Injects** the right environment variables
4. **Stops** the server when the session ends

You just speak. In any language.

## Supported languages

<details>
<summary><strong>60+ languages</strong> (click to expand)</summary>

| Language | Code | Language | Code |
|----------|------|----------|------|
| Arabic | ar | Korean | ko |
| Chinese | zh | Norwegian | no |
| Czech | cs | Persian | fa |
| Danish | da | Polish | pl |
| Dutch | nl | Portuguese | pt |
| English | en | Romanian | ro |
| Finnish | fi | Russian | ru |
| French | fr | Slovak | sk |
| German | de | Spanish | es |
| Greek | el | Swedish | sv |
| **Hebrew** | **he** | Thai | th |
| Hindi | hi | Turkish | tr |
| Hungarian | hu | Ukrainian | uk |
| Indonesian | id | Vietnamese | vi |
| Italian | it | Japanese | ja |

And many more... Soniox supports 60+ languages with automatic detection.

</details>

## Commands

| Command | What it does |
|---------|-------------|
| `/cc-universal-voice:start` | Manually start the voice server |
| `/cc-universal-voice:stop` | Stop the voice server |
| `/cc-universal-voice:status` | Check server status + recent logs |

## Requirements

- **Python 3.10+** (`python3 --version` to check)
- **Claude Code v1.0.33+** (plugin support)
- **Soniox API key** (optional &mdash; falls back to built-in voice without it)

## Troubleshooting

<details>
<summary><strong>"No speech detected"</strong></summary>

The voice server may not have started. Run:
```
/cc-universal-voice:start
```
Then try `/voice` again.
</details>

<details>
<summary><strong>Server not starting</strong></summary>

Check Python version:
```bash
python3 --version  # needs 3.10+
```

Check logs:
```bash
cat ~/.claude/plugins/data/cc-universal-voice/voice_server.log
```
</details>

<details>
<summary><strong>Plugin not loading after install</strong></summary>

Run inside Claude Code:
```
/reload-plugins
```
If that doesn't work, restart Claude Code.
</details>

## Architecture

The plugin bundles a Python WebSocket server that bridges Claude Code's audio stream to Soniox's streaming API:

- **SessionStart hook** &mdash; installs deps + starts daemon + injects env vars
- **SessionEnd hook** &mdash; stops daemon
- **Fallback mode** &mdash; without Soniox key, proxies to Anthropic (native langs) or uses Vosk (offline)
- **Thread-safe bridge** &mdash; Soniox SDK is synchronous; the server uses `ThreadPoolExecutor` + `asyncio.Queue`

## License

[MIT](LICENSE)

---

<p align="center">
  <sub>Built with <a href="https://soniox.com">Soniox</a> &bull; Made for <a href="https://code.claude.com">Claude Code</a></sub>
</p>
