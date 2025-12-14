# Proof

**Proof** is a macOS application that helps you proofread, rewrite, and summarize text using AI. It integrates seamlessly into your workflow via macOS Services and supports any OpenAI-compatible API (ChatGPT, Gemini, Ollama, etc.).

## Features

*   **Menu Bar Application:** Always accessible from the menu bar.
*   **Quick Shortcuts:**
    *   **Proofread (Cmd+Shift+P by default):** Instantly processes selected text, proofreads it, and replaces it in-place.
    *   **Proofread in a Window (Cmd+Shift+O by default):** Opens the Proof UI with the selected text, allowing you to choose different proofreading goals and edit text.
*   **Customizable Backend:** Works with any OpenAI-compatible API.

## Installation

### Downloading
The latest version of built, signed, and notarized macOS binary can be downloaded from the "Releases" section.

### Building from Source

1.  Clone the repository:
2.  Open `Proof.xcodeproj` in Xcode.
3.  Ensure the target is set to **My Mac**.
4.  Build and Run (Cmd+R).

## Configuration
Before using the app, you must configure your AI provider settings.

1. Click the **Proof** icon in the menu bar (document icon).
2. Enter your API details:
    *   **API URL:** The base URL for the API (e.g., `https://api.openai.com/v1`).
    *   **API Key:** Your secret API key.
    *   **Model:** The model name to use (e.g., `gpt-4o`, `gemini-2.5-flash`).
3. Click **Test Connection** to verify.
4. Click **Save**.

## Usage

### Menu Bar
Click the menu bar icon to open the main popover. From here you can:
*   Enter or paste text manually.
*   Select a proofreading goal.
*   Process the text and copy the result.
*   Access settings.

### macOS Services
Select any text in any application (Notes, TextEdit, Browser, etc.), then select an option from the Services Menu (or use a shortcut):

*   **Proofread (Cmd+Shift+P by default):** Instantly processes selected text, proofreads it, and replaces it in-place.
*   **Proofread in a Window (Cmd+Shift+O by default):** Opens the Proof UI with the selected text, allowing you to choose different proofreading goals and edit text.

*Tip: You can change keyboard shortcuts to these services in **System Settings > Keyboard > Keyboard Shortcuts > Services > Text**.*

## Requirements
*   macOS 15.0 or later.
*   An API Key from an OpenAI-compatible provider (ChatGPT, Gemini, Ollama, etc.).

## License
Licensed under Apache 2.0 license.
