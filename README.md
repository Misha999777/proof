# Proof

A Windows proofreading application. Select text anywhere, press **Ctrl+Alt+P**, and get instant AI-powered corrections, rewrites, and summaries.

## Features

- **Global Hotkey** — `Ctrl+Alt+P` captures selected text from any application via Windows UI Automation
- **System Tray** — Runs silently in the background with a tray icon
- **OpenAI-compatible API** — Works with any API that implements the `/chat/completions` endpoint
- **Multiple Modes** — Fix grammar, make text professional/friendly/concise, or summarize
- **Diff View** — Side-by-side word-level diff highlighting for grammar corrections
- **Follow-up Prompts** — Refine results with additional instructions

## Architecture

| Layer    | Tech                                                            |
|----------|-----------------------------------------------------------------|
| Backend  | C++, Win32, [saucer](https://github.com/saucer/saucer)          |
| Frontend | Vite, React, [Fluent UI](https://github.com/microsoft/fluentui) |
