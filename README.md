# gemini-cli

Gemini AI client for your terminal — written purely in bash for macOS/linux

```
$ gemini "explain how sed works"

sed (stream editor) processes text line by line using pattern-action rules...
  • -e allows multiple expressions in one command
  • -i edits files in-place
  • s/old/new/g is the substitution command

[↑ 12 tokens  ↓ 184 tokens  •  gemini-3.0-flash]
```

---

## Install

**One-liner (recommended):**
```bash
curl -sL https://raw.githubusercontent.com/arnavgr/gemini-cli/main/install.sh | bash
```

**Custom install prefix (no sudo needed):**
```bash
curl -sL https://raw.githubusercontent.com/YOUR_USERNAME/gemini-cli/main/install.sh | bash -s -- --prefix ~/.local
```

**Manual:**
```bash
git clone https://github.com/arnavgr/gemini-cli
cd gemini-cli
chmod +x gemini
sudo mv gemini /usr/local/bin/gemini
```

**Uninstall:**
```bash
curl -sL https://raw.githubusercontent.com/YOUR_USERNAME/gemini-cli/main/install.sh | bash -s -- --uninstall
```

---

## Requirements

| Tool  | Purpose                     | Install             |
|-------|-----------------------------|---------------------|
| `curl` | HTTP requests + streaming  | usually pre-installed |
| `jq`  | JSON parsing                | `sudo apt install jq` |
| `sed` / `awk` | Markdown rendering  | pre-installed everywhere |

Optional (for `--copy`): `xclip`, `xsel`, `wl-copy` (Wayland), or `pbcopy` (macOS).

---

## API Key

On first run, gemini will ask you to paste your API key and save it automatically.

Get a free key at: https://aistudio.google.com/app/apikey

The key is stored in `~/.gemini_key` with `chmod 600`.  
You can also set it as an environment variable (takes priority):

```bash
export GEMINI_API_KEY="your-key-here"
```

---

## Usage

```
gemini [flags] "your prompt"
echo "context" | gemini "your prompt"
cat file.txt   | gemini "summarize this"
```

### Flags

| Flag | Description |
|------|-------------|
| `--model <name>` | Use a specific model (persists to config) |
| `--session <name\|number>` | Use a named or numbered conversation session |
| `--system <text>` | Set a system instruction for this call |
| `--new` | Clear current session and start fresh |
| `--list-sessions` | List all saved sessions with numbers |
| `--delete-session <name\|#>` | Delete a session by name or number |
| `--rename-session <name\|#> <new>` | Rename a session |
| `--copy` | Copy response to clipboard |
| `--update` | Update to the latest version from GitHub |
| `--raw` | Print raw markdown without rendering |
| `--version` | Show version |
| `--help` | Show help |

---

## Sessions

Sessions let you maintain separate ongoing conversations.

```bash
# Start or continue a named session
gemini --session work "what tasks did I list earlier?"

# Use a session by its number (from --list-sessions)
gemini --session 3 "continue"

# See all sessions
gemini --list-sessions

#   NUM    NAME                 TURNS    LAST MODIFIED
#   ───    ────────────────────  ─────    ─────────────
#   001    default               4t       2025-01-10 14:32  ←
#   002    work                  12t      2025-01-10 09:15
#   003    debugging             2t       2025-01-09 22:41

# Rename session 2
gemini --rename-session 2 project-alpha

# Delete by name or number
gemini --delete-session work
gemini --delete-session 3

# Clear history but keep the session
gemini --session work --new
```

Sessions are stored in `~/.local/share/gemini/sessions/` as numbered JSON files (e.g. `002_work.json`).

---

## Models

```bash
# Switch model (saved for future calls)
gemini --model gemini-3.1-pro "explain quantum entanglement"
```

| Model | Speed | Best for |
|-------|-------|----------|
| `gemini-3.0-flash` | ⚡⚡⚡ | Default, everyday tasks |
| `gemini-3.1-flash-lite` | ⚡⚡⚡⚡ | Fastest, simple queries |
| `gemini-3.1-pro` | ⚡ | Complex reasoning, long context |

The selected model persists to `~/.config/gemini/config` — no need to repeat it.

---

## Examples

```bash
# Basic question
gemini "what is the difference between tcp and udp?"

# Pipe a file
cat server.log | gemini "what errors are here and why?"

# Pipe + prompt combined
cat script.py | gemini "refactor this to be more readable"

# System prompt (persona)
gemini --system "you are a terse linux sysadmin" "how do I find files over 1GB?"

# Copy response to clipboard
gemini --copy "write a git commit message for adding dark mode"

# Named session for ongoing work
gemini --session myproject "here's my project structure: ..."
gemini --session myproject "now write tests for the auth module"

# Update to latest version
gemini --update
```

---

## Configuration

Config is stored in `~/.config/gemini/config`:

```ini
# gemini config
model=gemini-2.0-flash
```

You can edit this file directly. Currently supported keys: `model`.

---

## File locations

| Path | Purpose |
|------|---------|
| `~/.gemini_key` | API key (chmod 600) |
| `~/.config/gemini/config` | Persistent settings |
| `~/.local/share/gemini/sessions/` | Conversation history |

---

## License

MIT
