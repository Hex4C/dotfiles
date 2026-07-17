# AGENTS.md — Global Workflows for pi.dev

## Repository Workflow

1. **Inspect First:** Map out nearby patterns using `ffgrep`/`fffind` before making edits. Do not change public APIs, schemas, or migrations beyond the requested scope.
2. **Safety First:** Treat the working tree as user-owned. Check `git status` or file state before making potentially overlapping edits. Do not overwrite uncommitted changes or perform destructive actions (e.g., deleting files, force-pushing, resetting branches) unless explicitly asked.
3. **Zero Leakage:** Never expose or write secrets, tokens, credentials, or private data to files or output.
4. **Verification:** Run the narrowest relevant test or linter after an edit. If tests cannot be run locally, state the exact command the user needs to execute. Do not fake test passes.
5. **Completion Summary:** For code changes, conclude with a single concise summary block:
   - **Files Changed:** `[paths]`
   - **Summary:** `[1-sentence overview]`
   - **Verification:** `[Command run or user verification step]`

---

## Workspace & Search Guidelines

- **Targeted Searches:** Always prioritize `fffind` and `ffgrep` using bare identifiers to locate files and patterns efficiently and save token context. Avoid broad, recursive search commands on root.
- **Large File Defense:** Before reading any file, check its size. If a file is **>150 lines**, do not use `read`. Use targeted `bash` commands (e.g., `sed -n '10,50p'`, `head`, or `tail`) to inspect only the relevant lines.
- **Exclude Noise:** Always filter out unneeded directories using exclusion patterns: `test/,*.min.js,dist/,build/`.

---

## Edit vs. Write Strategy

- **Precise Edits:** Use `edit` for precise changes. Keep `oldText` matches as small and unique as possible. Split major revisions into progressive, smaller edits instead of wiping and rewriting large files.
- **Full Writes:** Use `write` only when creating entirely new files or doing a complete rewrite of short, simple files.
