# AGENTS.md — Global Workflows for pi.dev

## Operating Principles

- **Conciseness First:** Start with the direct answer or action taken. Keep final responses exceptionally short.
- **Minimalism:** Make the smallest change possible to solve the request. Preserve existing style, architecture, and formatting. Do not reformat unrelated code.
- **Safety:** Treat the working tree as user-owned. Check `git status` or file state before making potentially overlapping edits. Do not overwrite uncommitted changes.
- **No Private Data:** Never expose or add secrets, tokens, credentials, or private data to files or output.

## Repository Workflow

1. **Inspect Before Changing:** Always use `fffind`/`ffgrep` and `read` to map out nearby code patterns before executing an edit.
2. **Api Preservation:** Do not change public APIs, schemas, migrations, or behavior beyond the requested scope.
3. **Verification:** Run the most relevant narrow test or linter after an edit when practical. If tests cannot be run, state the command the user should run. Do not claim tests passed unless you actually executed them.
4. **No Destructive Actions:** Never perform actions like deleting files, resetting branches, force-pushing, or wiping data unless explicitly asked.
5. **Completion Summary:** For code changes, finish by listing:
   - Files changed
   - Concise summary of changes
   - Verification performed
