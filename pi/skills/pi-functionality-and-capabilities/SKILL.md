---
description: Understand pi-coding-agent internals — extensions, docs, SDK, tools, and architecture. Use when the user asks about how pi works, its capabilities, plugin system, or asks to reason about pi's codebase.
---

# Pi Functionality, Capabilities & Documentation

This skill covers how to explore pi's internals — its extension architecture, tools, SDK, and documentation.

## Pi installation root

```
/opt/homebrew/lib/node_modules/@earendil-works/pi-coding-agent
```

Let `PI_ROOT` denote the path above throughout this skill.

## Searching pi's source

Pi's source lives **outside the project workspace**, but `ffgrep` and `fffind` accept absolute and `~/` paths outside the workspace (searched via a separate index), so you can point them straight at `PI_ROOT` without repo-relative paths.

For example:

```
ffgrep "ExtensionAPI" /opt/homebrew/lib/node_modules/@earendil-works/pi-coding-agent/dist --exclude '*.map'
fffind "*.d.ts" /opt/homebrew/lib/node_modules/@earendil-works/pi-coding-agent/dist
```

Fall back to `bash` with `rg`/`fd`/`find` against `PI_ROOT` only when you need flags `ffgrep`/`fffind` don't expose (e.g. file-type filtering with `--type ts`, or `-l` count semantics).

## Key directories

| Path                              | Contents                                                                    |
| --------------------------------- | --------------------------------------------------------------------------- |
| `PI_ROOT/docs/`                   | Documentation (extensions.md, sdk.md, skills.md, tui.md, sessions.md, etc.) |
| `PI_ROOT/examples/`               | Example extensions, SDK usage, RPC integration                              |
| `PI_ROOT/examples/extensions/`    | Concrete extension examples                                                 |
| `PI_ROOT/dist/`                   | Compiled JS + type declarations                                             |
| `PI_ROOT/dist/core/extensions/`   | Extension system — types.d.ts is the master type reference                  |
| `PI_ROOT/dist/core/tools/`        | Built-in tool implementations (read, edit, write, bash, grep, find, ls)     |
| `PI_ROOT/dist/core/`              | Core modules: skills, system-prompt, session-manager, agent-session, etc.   |
| `PI_ROOT/dist/modes/interactive/` | TUI mode components                                                         |
| `PI_ROOT/dist/utils/`             | Utilities: clipboard-image, image-process, mime, etc.                       |

## Search patterns

`ffgrep`/`fffind` accept `PI_ROOT` as an absolute or `~` path outside the workspace; add `--exclude` to drop noise like source maps:

```txt
# Find where a concept is implemented
ffgrep "ExtensionAPI" /opt/homebrew/lib/node_modules/@earendil-works/pi-coding-agent/dist

# Search type declarations for API surfaces
ffgrep "registerTool|registerCommand|registerProvider" /opt/homebrew/lib/node_modules/@earendil-works/pi-coding-agent/dist --exclude '*.map'

# Find event handlers
ffgrep 'pi\.on\(' /opt/homebrew/lib/node_modules/@earendil-works/pi-coding-agent/examples

# Search docs for a topic
ffgrep "topic" /opt/homebrew/lib/node_modules/@earendil-works/pi-coding-agent/docs

# List all TypeScript type files
fffind "*.d.ts" /opt/homebrew/lib/node_modules/@earendil-works/pi-coding-agent/dist

# Find how a built-in tool works
fffind "read." /opt/homebrew/lib/node_modules/@earendil-works/pi-coding-agent/dist/core/tools/
```

Use `bash` with `rg`/`fd`/`find` only when you need flags these tools don't provide (e.g. `rg --type ts`, `rg -l`, `fd -e ts`).

## Understanding pi's architecture

### Extensions (the plugin system)

- **Read first:** `PI_ROOT/docs/extensions.md`
- **Type definitions:** `PI_ROOT/dist/core/extensions/types.d.ts` — the full `ExtensionAPI` interface
- **Examples:** `PI_ROOT/examples/extensions/`
- Extensions are TypeScript modules with a default export function `(pi: ExtensionAPI) => void`
- They hook into lifecycle events (`pi.on("tool_call", ...)`, `pi.on("input", ...)`, etc.)
- They register tools (`pi.registerTool(...)`), commands (`pi.registerCommand(...)`), and keybindings

### Skills

- **Read first:** `PI_ROOT/docs/skills.md`
- Skills are Markdown files with YAML frontmatter (`description` required)
- Loaded from `~/.pi/agent/skills/`, `.pi/skills/`, `.agents/skills/`
- Auto-injected into the system prompt as `<available_skills>` XML
- Model uses `read` tool to load the full SKILL.md when task matches description

### Built-in tools

- Each tool in `PI_ROOT/dist/core/tools/` has its own file (read.js, edit.js, etc.)
- Tools are defined via `createXToolDefinition()` returning a `ToolDefinition`
- The `read` tool supports images (jpg, png, gif, webp, bmp) via `image-process.js` and `clipboard-image.js`

### System prompt

- Built in `PI_ROOT/dist/core/system-prompt.js`
- Pulls in skills via `formatSkillsForPrompt()`, context files (AGENTS.md), and tool guidelines
- Custom system prompt via `~/.pi/agent/SYSTEM.md` (replace) or `APPEND_SYSTEM.md` (extend)

### Sessions

- **Read:** `PI_ROOT/docs/sessions.md`, `PI_ROOT/docs/session-format.md`
- Sessions are JSONL trees with `id`/`parentId`, stored in `~/.pi/agent/sessions/`
- Support branching (`/tree`), forking, compaction

### Providers & models

- **Read:** `PI_ROOT/docs/providers.md`, `PI_ROOT/docs/models.md`, `PI_ROOT/docs/custom-provider.md`
- Extensions can register custom providers via `pi.registerProvider()`
- Custom models via `~/.pi/agent/models.json`

## Strategy when answering pi questions

1. Start by reading the relevant doc under `PI_ROOT/docs/` for the topic
2. Cross-reference with type definitions in `PI_ROOT/dist/` for API accuracy
3. Check examples under `PI_ROOT/examples/` for real-world usage
4. When unsure about implementation details, grep the compiled JS in `PI_ROOT/dist/` — the source-of-truth is what ships, not what's documented
