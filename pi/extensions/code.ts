/**
 * /code — Compact, header-level map of a codebase for fast orientation.
 *
 * Purpose: give the coding agent a cheap, on-demand overview of an unfamiliar
 * project (a lightweight stand-in for a missing AGENTS.md). The map lists every
 * source file with its *function/type headers* (signatures) and line numbers —
 * deliberately minimal, so it is cheap to pull and easy to scan. From there the
 * agent traverses efficiently: ffgrep a symbol name to find its usages, or read
 * the file at the given line. ffgrep is only relevant for the deeper `explain`
 * lookups, never for the base overview.
 *
 * Surfaces:
 *   - Tools (agent-callable):
 *       code_overview  → compact header map of the repo (orientation)
 *       code_explain   → focused headers for one file / symbol / topic
 *   - Commands (user-invoked): /code summary | overview | explain <target>
 *
 * The extractors are dependency-free and language-aware (no network); they
 * capture declaration headers rather than a full AST, which is all that is
 * needed for orientation.
 */

import * as fs from "node:fs";
import * as path from "node:path";
import { Type } from "typebox";
import type {
  ExtensionAPI,
  ExtensionCommandContext,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";

// ── Configuration ─────────────────────────────────────────────────────

/** Directories never worth walking. */
const IGNORE_DIRS = new Set([
  "node_modules",
  ".git",
  ".hg",
  ".svn",
  "dist",
  "build",
  "out",
  "bin",
  "obj",
  "target",
  "vendor",
  ".next",
  ".nuxt",
  ".svelte-kit",
  "coverage",
  ".venv",
  "venv",
  "env",
  "__pycache__",
  ".mypy_cache",
  ".pytest_cache",
  ".idea",
  ".vscode",
  ".cache",
  ".turbo",
  ".parcel-cache",
  ".gradle",
  "Pods",
  "DerivedData",
  ".terraform",
  ".pi",
]);

/** Files skipped by name/suffix (locks, minified, maps). */
const IGNORE_FILE =
  /(^|\/)(package-lock\.json|pnpm-lock\.yaml|yarn\.lock|poetry\.lock|Cargo\.lock|composer\.lock)$|\.min\.(js|css)$|\.map$/;

const MAX_FILES = 800; // hard cap on files parsed
const MAX_FILE_BYTES = 512 * 1024;
const MAX_SYMBOLS_PER_FILE = 80; // minimized: headers only
const MAX_HEADER_CHARS = 160; // truncate long signatures
const OVERVIEW_MAX_DEPTH = 1; // top-level + one nested level
const MAX_MAP_CHARS = 40_000; // cap the rendered overview
const MAX_EXPLAIN_CHARS = 24_000;

// ── Language detection ────────────────────────────────────────────────

type Family = "cstyle" | "python" | "go" | "rust" | "ruby";

interface LangConfig {
  name: string;
  family: Family;
}

const EXT_LANG: Record<string, LangConfig> = {
  ".ts": { name: "ts", family: "cstyle" },
  ".tsx": { name: "tsx", family: "cstyle" },
  ".js": { name: "js", family: "cstyle" },
  ".jsx": { name: "jsx", family: "cstyle" },
  ".mjs": { name: "js", family: "cstyle" },
  ".cjs": { name: "js", family: "cstyle" },
  ".java": { name: "java", family: "cstyle" },
  ".kt": { name: "kotlin", family: "cstyle" },
  ".kts": { name: "kotlin", family: "cstyle" },
  ".scala": { name: "scala", family: "cstyle" },
  ".swift": { name: "swift", family: "cstyle" },
  ".c": { name: "c", family: "cstyle" },
  ".h": { name: "c", family: "cstyle" },
  ".cc": { name: "cpp", family: "cstyle" },
  ".cpp": { name: "cpp", family: "cstyle" },
  ".cxx": { name: "cpp", family: "cstyle" },
  ".hpp": { name: "cpp", family: "cstyle" },
  ".cs": { name: "csharp", family: "cstyle" },
  ".php": { name: "php", family: "cstyle" },
  ".py": { name: "python", family: "python" },
  ".pyi": { name: "python", family: "python" },
  ".go": { name: "go", family: "go" },
  ".rs": { name: "rust", family: "rust" },
  ".rb": { name: "ruby", family: "ruby" },
};

function detectLang(file: string): LangConfig | undefined {
  return EXT_LANG[path.extname(file).toLowerCase()];
}

// ── Symbol model ──────────────────────────────────────────────────────

interface Sym {
  depth: number;
  kind: string;
  /** Bare identifier — kept ffgrep-friendly for follow-up lookups. */
  name: string;
  /** Cleaned declaration header (signature) shown in the map. */
  signature: string;
  line: number;
}

interface FileMap {
  rel: string;
  lang: string;
  loc: number;
  symbols: Sym[];
}

// Keywords that look like calls but are control flow, not declarations.
const CONTROL_KEYWORDS = new Set([
  "if",
  "for",
  "while",
  "switch",
  "catch",
  "return",
  "do",
  "else",
  "case",
  "typeof",
  "new",
  "await",
  "yield",
  "throw",
  "with",
  "super",
  "constructor",
  "function",
  "class",
  "interface",
  "enum",
  "struct",
]);

/** Reduce a declaration line to a clean single-line header (its signature). */
function toHeader(raw: string): string {
  let s = raw.trim();
  const brace = s.indexOf("{");
  if (brace >= 0) s = s.slice(0, brace);
  s = s
    .replace(/=>\s*$/, "")
    .replace(/[=:]\s*$/, "")
    .replace(/;\s*$/, "")
    .replace(/\s+/g, " ")
    .trim();
  if (s.length > MAX_HEADER_CHARS) s = s.slice(0, MAX_HEADER_CHARS - 1) + "…";
  return s;
}

/**
 * Cross-line state for brace scanning: whether we're currently inside a
 * `/* *\/` block comment or an unterminated string/template literal that
 * spans lines. Carried between lines so multi-line constructs don't desync
 * the brace-depth counter.
 */
interface ScanState {
  inBlockComment: boolean;
  quote: string | null;
}

/**
 * Strip line/block comments and string/char/template literals so brace
 * counting is sane. `state` persists across lines to handle multi-line block
 * comments and multi-line strings/template literals.
 */
function stripForBraces(line: string, state: ScanState): string {
  let out = "";
  let i = 0;
  while (i < line.length) {
    const c = line[i];
    if (state.inBlockComment) {
      if (c === "*" && line[i + 1] === "/") {
        state.inBlockComment = false;
        i += 2;
        continue;
      }
      i++;
      continue;
    }
    if (state.quote) {
      if (c === "\\") {
        i += 2;
        continue;
      }
      if (c === state.quote) state.quote = null;
      i++;
      continue;
    }
    if (c === "/" && line[i + 1] === "/") break;
    if (c === "/" && line[i + 1] === "*") {
      state.inBlockComment = true;
      i += 2;
      continue;
    }
    if (c === '"' || c === "'" || c === "`") {
      state.quote = c;
      i++;
      continue;
    }
    out += c;
    i++;
  }
  return out;
}

function isCommentLine(t: string): boolean {
  return (
    t.startsWith("//") ||
    t.startsWith("*") ||
    t.startsWith("/*") ||
    t.startsWith("#") ||
    t.startsWith("--")
  );
}

// ── C-style extractor (JS/TS, Java, C/C++, C#, Kotlin, Swift, PHP, …) ──

const CSTYLE_DECLS: Array<{ kind: string; re: RegExp }> = [
  { kind: "class", re: /\bclass\s+([A-Za-z_$][\w$]*)/ },
  { kind: "iface", re: /\binterface\s+([A-Za-z_$][\w$]*)/ },
  { kind: "enum", re: /\benum\s+(?:class\s+)?([A-Za-z_$][\w$]*)/ },
  { kind: "struct", re: /\bstruct\s+([A-Za-z_$][\w$]*)/ },
  { kind: "trait", re: /\b(?:trait|protocol)\s+([A-Za-z_$][\w$]*)/ },
  { kind: "type", re: /\btype\s+([A-Za-z_$][\w$]*)\s*[=<]/ },
  { kind: "func", re: /\bfunction\s*\*?\s+([A-Za-z_$][\w$]*)/ },
  { kind: "func", re: /\bfun\s+([A-Za-z_$][\w$]*)/ }, // kotlin
  {
    kind: "func",
    re: /\b(?:export\s+)?(?:const|let|var)\s+([A-Za-z_$][\w$]*)\s*(?::[^=]+)?=\s*(?:async\s*)?(?:function\b|\([^)]*\)\s*(?::[^=]+)?=>|[A-Za-z_$][\w$]*\s*=>)/,
  },
];

// A method / free function defined with `name(...) {` or `name(...):`.
const CSTYLE_METHOD =
  /^(?:@[\w.]+\s+)*(?:(?:public|private|protected|internal|static|final|abstract|virtual|override|async|inline|export|default|readonly|get|set|suspend|open|const|func|def|fn|sub|operator|\*)\s+)*([A-Za-z_$][\w$]*)\s*(?:<[^>]*>)?\s*\([^;{]*\)\s*(?::[^;{]+|->[^;{]+|throws[^;{]+)?\s*\{/;

function extractCStyle(lines: string[]): Sym[] {
  const syms: Sym[] = [];
  let depth = 0;
  const state: ScanState = { inBlockComment: false, quote: null };
  for (let i = 0; i < lines.length; i++) {
    const raw = lines[i];
    const t = raw.trim();
    // Skip declarations while inside a block comment or multi-line string.
    if (!state.inBlockComment && !state.quote && t && !isCommentLine(t)) {
      let matched = false;
      for (const { kind, re } of CSTYLE_DECLS) {
        const m = raw.match(re);
        if (m) {
          syms.push({
            depth,
            kind,
            name: m[1],
            signature: toHeader(raw),
            line: i + 1,
          });
          matched = true;
          break;
        }
      }
      if (!matched) {
        // Match against the trimmed line: CSTYLE_METHOD is `^`-anchored, so
        // matching `raw` would miss every indented (e.g. in-class) method.
        const mm = t.match(CSTYLE_METHOD);
        if (mm && !CONTROL_KEYWORDS.has(mm[1])) {
          syms.push({
            depth,
            kind: depth > 0 ? "method" : "func",
            name: mm[1],
            signature: toHeader(raw),
            line: i + 1,
          });
        }
      }
    }
    // Track brace depth after processing the line.
    const s = stripForBraces(raw, state);
    for (const ch of s) {
      if (ch === "{") depth++;
      else if (ch === "}") depth = Math.max(0, depth - 1);
    }
  }
  return syms;
}

// ── Python extractor (indentation based) ──────────────────────────────

function extractPython(lines: string[]): Sym[] {
  const syms: Sym[] = [];
  const stack: number[] = []; // indent widths of open blocks
  for (let i = 0; i < lines.length; i++) {
    const raw = lines[i];
    const t = raw.trim();
    if (!t || t.startsWith("#")) continue;
    const indent = raw.length - raw.trimStart().length;
    const m = raw.match(/^\s*(?:async\s+)?(class|def)\s+([A-Za-z_]\w*)/);
    if (!m) continue;
    while (stack.length && indent <= stack[stack.length - 1]) stack.pop();
    const depth = stack.length;
    const kind = m[1] === "class" ? "class" : depth > 0 ? "method" : "func";
    syms.push({
      depth,
      kind,
      name: m[2],
      signature: toHeader(raw),
      line: i + 1,
    });
    stack.push(indent);
  }
  return syms;
}

// ── Go extractor ──────────────────────────────────────────────────────

function extractGo(lines: string[]): Sym[] {
  const syms: Sym[] = [];
  for (let i = 0; i < lines.length; i++) {
    const raw = lines[i];
    let m = raw.match(/^func\s+(?:\([^)]*\)\s*)?([A-Za-z_]\w*)/);
    if (m) {
      syms.push({
        depth: 0,
        kind: "func",
        name: m[1],
        signature: toHeader(raw),
        line: i + 1,
      });
      continue;
    }
    m = raw.match(/^type\s+([A-Za-z_]\w*)\s+(struct|interface)\b/);
    if (m) {
      syms.push({
        depth: 0,
        kind: m[2],
        name: m[1],
        signature: toHeader(raw),
        line: i + 1,
      });
      continue;
    }
  }
  return syms;
}

// ── Rust extractor ────────────────────────────────────────────────────

function extractRust(lines: string[]): Sym[] {
  const syms: Sym[] = [];
  let depth = 0;
  const state: ScanState = { inBlockComment: false, quote: null };
  for (let i = 0; i < lines.length; i++) {
    const raw = lines[i];
    const t = raw.trim();
    if (!state.inBlockComment && !state.quote && t && !t.startsWith("//")) {
      const m = t.match(
        /^(?:pub(?:\([^)]*\))?\s+)?(?:async\s+)?(?:unsafe\s+)?(fn|struct|enum|trait|impl|mod|type|const|static)\s+([A-Za-z_]\w*)/,
      );
      if (m)
        syms.push({
          depth,
          kind: m[1],
          name: m[2],
          signature: toHeader(raw),
          line: i + 1,
        });
    }
    const s = stripForBraces(raw, state);
    for (const ch of s) {
      if (ch === "{") depth++;
      else if (ch === "}") depth = Math.max(0, depth - 1);
    }
  }
  return syms;
}

// ── Ruby extractor ────────────────────────────────────────────────────

// Leading keywords that open an `end`-terminated block.
const RUBY_BLOCK_OPENER =
  /^(?:class|module|def|if|unless|case|begin|while|until|for)\b/;
// A trailing `do ... end` block, e.g. `items.each do |x|`.
const RUBY_DO_BLOCK = /\bdo\b(?:\s*\|[^|]*\|)?\s*(?:#.*)?$/;

/**
 * Net nesting change for a Ruby line: block openers (+1) vs. `end` (−1).
 * Only leading keywords count as openers, so trailing modifiers
 * (`foo if bar`) are correctly ignored; inline blocks (`def f; end`) net zero.
 */
function rubyDelta(t: string): number {
  let opens = 0;
  if (RUBY_BLOCK_OPENER.test(t)) opens++;
  else if (RUBY_DO_BLOCK.test(t)) opens++; // `while … do` reuses its keyword
  const ends = t.match(/\bend\b/g)?.length ?? 0;
  return opens - ends;
}

function extractRuby(lines: string[]): Sym[] {
  const syms: Sym[] = [];
  let depth = 0;
  for (let i = 0; i < lines.length; i++) {
    const raw = lines[i];
    const t = raw.trim();
    if (!t || t.startsWith("#")) continue;
    let m = t.match(/^(class|module)\s+([A-Za-z_][\w:]*)/);
    if (m) {
      syms.push({
        depth,
        kind: m[1],
        name: m[2],
        signature: toHeader(raw),
        line: i + 1,
      });
    } else {
      m = t.match(/^def\s+([A-Za-z_][\w?!.=]*)/);
      if (m) {
        syms.push({
          depth,
          kind: "method",
          name: m[1],
          signature: toHeader(raw),
          line: i + 1,
        });
      }
    }
    // Balance openers against `end` so a method's own `end` no longer closes
    // its enclosing class/module (which sank later siblings to depth 0).
    depth = Math.max(0, depth + rubyDelta(t));
  }
  return syms;
}

function extractSymbols(source: string, cfg: LangConfig): Sym[] {
  const lines = source.split(/\r?\n/);
  let syms: Sym[];
  switch (cfg.family) {
    case "python":
      syms = extractPython(lines);
      break;
    case "go":
      syms = extractGo(lines);
      break;
    case "rust":
      syms = extractRust(lines);
      break;
    case "ruby":
      syms = extractRuby(lines);
      break;
    default:
      syms = extractCStyle(lines);
      break;
  }
  return syms.slice(0, MAX_SYMBOLS_PER_FILE);
}

// ── Codebase walk ─────────────────────────────────────────────────────

interface CodebaseMap {
  root: string;
  files: FileMap[];
  totalLoc: number;
  langCounts: Record<string, number>;
  truncated: boolean;
}

function walk(root: string): string[] {
  const found: string[] = [];
  const stack: string[] = [root];
  while (stack.length && found.length < MAX_FILES) {
    const dir = stack.pop()!;
    let entries: fs.Dirent[];
    try {
      entries = fs.readdirSync(dir, { withFileTypes: true });
    } catch {
      continue;
    }
    entries.sort((a, b) => a.name.localeCompare(b.name));
    for (const e of entries) {
      if (e.isDirectory()) {
        if (e.name.startsWith(".")) continue; // skip dotdirs
        if (IGNORE_DIRS.has(e.name)) continue;
        stack.push(path.join(dir, e.name));
      } else if (e.isFile()) {
        const full = path.join(dir, e.name);
        if (IGNORE_FILE.test(full)) continue;
        if (detectLang(full)) found.push(full);
      }
    }
  }
  return found;
}

function buildMap(root: string): CodebaseMap {
  const files = walk(root);
  const truncated = files.length >= MAX_FILES;
  const maps: FileMap[] = [];
  const langCounts: Record<string, number> = {};
  let totalLoc = 0;

  for (const file of files) {
    const cfg = detectLang(file)!;
    let stat: fs.Stats;
    try {
      stat = fs.statSync(file);
    } catch {
      continue;
    }
    if (stat.size > MAX_FILE_BYTES) continue;
    let source: string;
    try {
      source = fs.readFileSync(file, "utf8");
    } catch {
      continue;
    }
    if (source.includes(" ")) continue; // skip binary files (NUL byte)
    const loc = source.split(/\r?\n/).length;
    totalLoc += loc;
    langCounts[cfg.name] = (langCounts[cfg.name] ?? 0) + 1;
    maps.push({
      rel: path.relative(root, file) || path.basename(file),
      lang: cfg.name,
      loc,
      symbols: extractSymbols(source, cfg),
    });
  }

  maps.sort((a, b) => a.rel.localeCompare(b.rel));
  return { root, files: maps, totalLoc, langCounts, truncated };
}

// ── Rendering ─────────────────────────────────────────────────────────

const KIND_GLYPH: Record<string, string> = {
  class: "◆",
  iface: "◇",
  struct: "▢",
  enum: "▤",
  trait: "◈",
  module: "▧",
  mod: "▧",
  type: "≡",
  func: "ƒ",
  method: "·",
  impl: "⊕",
};

function renderFileMap(fm: FileMap, maxDepth: number): string {
  const header = `${fm.rel}  [${fm.lang}, ${fm.loc} loc]`;
  const shown = fm.symbols.filter((s) => s.depth <= maxDepth);
  if (shown.length === 0) return header;
  const body = shown
    .map((s) => {
      const indent = "  ".repeat(Math.min(s.depth, maxDepth) + 1);
      const glyph = KIND_GLYPH[s.kind] ?? "•";
      return `${indent}${glyph} ${s.signature}  ·L${s.line}`;
    })
    .join("\n");
  return `${header}\n${body}`;
}

function mapHeader(map: CodebaseMap): string {
  const langSummary = Object.entries(map.langCounts)
    .sort((a, b) => b[1] - a[1])
    .map(([l, n]) => `${l}:${n}`)
    .join("  ");
  return (
    `repo map — ${map.root}\n` +
    `${map.files.length} source files, ~${map.totalLoc} LOC  (${langSummary})\n` +
    (map.truncated ? `NOTE: file cap reached; map is partial.\n` : "")
  );
}

function renderOverview(map: CodebaseMap): {
  text: string;
  truncated: boolean;
} {
  const head = mapHeader(map);
  const parts: string[] = [];
  let size = head.length;
  let truncated = map.truncated;
  for (const fm of map.files) {
    const block = renderFileMap(fm, OVERVIEW_MAX_DEPTH);
    if (size + block.length + 2 > MAX_MAP_CHARS) {
      truncated = true;
      break;
    }
    parts.push(block);
    size += block.length + 2;
  }
  return { text: head + "\n" + parts.join("\n\n"), truncated };
}

/**
 * Focus the map on a single file, symbol, or topic.
 * Deeper reference lookups are left to ffgrep on the returned identifiers.
 */
function renderExplain(map: CodebaseMap, target: string): string {
  const needle = target.toLowerCase();

  // 1) Exact file match (target is a path).
  const fileHit = map.files.find(
    (f) => f.rel === target || f.rel.toLowerCase() === needle,
  );
  if (fileHit) {
    return (
      `Focused view — file "${fileHit.rel}"\n\n` +
      renderFileMap(fileHit, 99) +
      `\n\nFor callers/usages, ffgrep a symbol name above.`
    );
  }

  // 2) Path substring or symbol-name match across the map.
  const blocks: string[] = [];
  let size = 0;
  let matchedSymbols = 0;
  for (const fm of map.files) {
    const pathMatch = fm.rel.toLowerCase().includes(needle);
    const symMatches = fm.symbols.filter((s) =>
      s.name.toLowerCase().includes(needle),
    );
    if (!pathMatch && symMatches.length === 0) continue;
    matchedSymbols += symMatches.length;
    const focus: FileMap = {
      ...fm,
      symbols: pathMatch ? fm.symbols : symMatches,
    };
    const block = renderFileMap(focus, 99);
    if (size + block.length > MAX_EXPLAIN_CHARS) break;
    blocks.push(block);
    size += block.length + 2;
  }

  if (blocks.length === 0) {
    return (
      `No file path or symbol in the map matches "${target}".\n` +
      `Try ffgrep "${target}" to search file contents directly, or call ` +
      `code_overview to see what's available.`
    );
  }

  return (
    `Focused view — "${target}" (${matchedSymbols} matching symbol(s))\n\n` +
    blocks.join("\n\n") +
    `\n\nThese are headers only. Read a file at the listed line, or ffgrep a ` +
    `symbol name for its usages, to go deeper.`
  );
}

// ── Prompt construction (for user commands) ───────────────────────────

function overviewPrompt(
  mapText: string,
  style: "summary" | "overview",
): string {
  const ask =
    style === "summary"
      ? `write a **concise summary**: what the project does, its primary ` +
        `language/stack, and how it is organized. A few tight paragraphs.`
      : `produce a **high-level architecture overview**: the major ` +
        `components and their responsibilities, key entry points, and how ` +
        `data/control flows between them. Use headings and bullets.`;
  return (
    `Below is a compact header-level map of this codebase (files with their ` +
    `function/type signatures). Working primarily from this map — only opening ` +
    `a file if a specific detail is missing — ${ask}\n\n` +
    `<repo-map>\n${mapText}\n</repo-map>`
  );
}

function explainPrompt(target: string, focusText: string): string {
  return (
    `Explain this part of the codebase: \`${target}\`. Use the focused header ` +
    `view below to orient, then read the specific file(s) at the listed lines ` +
    `(and ffgrep a symbol for its usages) as needed. Cover the target's ` +
    `responsibility, its key functions, and how it connects to the rest.\n\n` +
    `<focus>\n${focusText}\n</focus>`
  );
}

// ── Shared helpers ────────────────────────────────────────────────────

/** Resolve an optional subdir, clamped to the project root. */
function resolveRoot(cwd: string, sub: string | undefined): string {
  if (!sub) return cwd;
  const resolved = path.resolve(cwd, sub);
  const base = path.resolve(cwd);
  if (resolved !== base && !resolved.startsWith(base + path.sep)) return cwd;
  try {
    if (fs.statSync(resolved).isDirectory()) return resolved;
  } catch {
    /* fall through */
  }
  return cwd;
}

function textResult(text: string, files: number) {
  return { content: [{ type: "text" as const, text }], details: { files } };
}

// ── Extension entry point ─────────────────────────────────────────────

const SUBCOMMANDS = ["summary", "overview", "explain"] as const;

const USAGE =
  "/code — compact header map of the codebase\n" +
  "  /code summary            Concise summary of what the codebase does\n" +
  "  /code overview           High-level architecture overview\n" +
  "  /code explain <target>   Focused headers for a file, symbol, or topic";

export default function (pi: ExtensionAPI) {
  // ── Agent-callable tool: orientation map ────────────────────────────
  pi.registerTool({
    name: "code_overview",
    label: "Code Overview",
    description:
      "Build a compact, header-level map of the codebase: every source file " +
      "with its function/type signatures and line numbers. Use it to orient " +
      "yourself in an unfamiliar project when no overview doc (e.g. AGENTS.md) " +
      "exists. Read-only and cheap. After reading the map, ffgrep a symbol " +
      "name or read a file at the listed line to go deeper.",
    promptSnippet:
      "code_overview — compact map of files + function headers to orient in a codebase",
    parameters: Type.Object({
      path: Type.Optional(
        Type.String({
          description:
            "Optional subdirectory (relative to the project root) to scope the map to.",
        }),
      ),
    }),
    execute: async (_id, params, _signal, _onUpdate, ctx: ExtensionContext) => {
      const root = resolveRoot(ctx.cwd, params.path);
      const map = buildMap(root);
      if (map.files.length === 0) {
        return textResult(
          "No recognizable source files found under this directory.",
          0,
        );
      }
      const { text } = renderOverview(map);
      return textResult(text, map.files.length);
    },
  });

  // ── Agent-callable tool: focused explain (deeper look) ──────────────
  pi.registerTool({
    name: "code_explain",
    label: "Code Explain",
    description:
      "Get a focused, header-level view of one part of the codebase — a file " +
      "path, a symbol/function name, or a short topic. Returns the matching " +
      "signatures with line numbers so you can decide what to read next. For " +
      "wider reference lookups, follow up with ffgrep on a symbol name from " +
      "the result.",
    promptSnippet:
      "code_explain — focused function headers for a file/symbol/topic",
    parameters: Type.Object({
      target: Type.String({
        description:
          "A file path, symbol/function name, or short topic to focus on.",
      }),
    }),
    execute: async (_id, params, _signal, _onUpdate, ctx: ExtensionContext) => {
      const map = buildMap(ctx.cwd);
      const text = renderExplain(map, params.target.trim());
      return textResult(text, map.files.length);
    },
  });

  // ── User command: /code summary | overview | explain <target> ───────
  pi.registerCommand("code", {
    description:
      "Compact header map of the codebase: summary / overview / explain",
    getArgumentCompletions: (prefix: string) => {
      const first = prefix.trimStart();
      if (first.includes(" ")) return null; // only complete the subcommand token
      return SUBCOMMANDS.filter((s) => s.startsWith(first)).map((s) => ({
        value: s,
        label: `/code ${s}`,
      }));
    },
    handler: async (args: string, ctx: ExtensionCommandContext) => {
      const trimmed = args.trim();
      const spaceIdx = trimmed.indexOf(" ");
      const sub = (
        spaceIdx === -1 ? trimmed : trimmed.slice(0, spaceIdx)
      ).toLowerCase();
      const rest = spaceIdx === -1 ? "" : trimmed.slice(spaceIdx + 1).trim();

      if (!sub) {
        ctx.ui.notify(USAGE, "info");
        return;
      }
      if (!SUBCOMMANDS.includes(sub as (typeof SUBCOMMANDS)[number])) {
        ctx.ui.notify(`Unknown subcommand "${sub}".\n${USAGE}`, "warning");
        return;
      }

      // Resolve the explain target (prompt for it interactively if missing).
      let target = rest;
      if (sub === "explain" && !target) {
        if (ctx.hasUI) {
          const answer = await ctx.ui.input(
            "Explain which part of the codebase?",
            "path/to/file.ts, a symbol name, or a topic",
          );
          if (!answer || !answer.trim()) return;
          target = answer.trim();
        } else {
          ctx.ui.notify(
            "Usage: /code explain <file | symbol | topic>",
            "warning",
          );
          return;
        }
      }

      ctx.ui.setStatus("code", "⏳ building repo map…");
      let map: CodebaseMap;
      try {
        map = buildMap(ctx.cwd);
      } finally {
        ctx.ui.setStatus("code", undefined);
      }

      if (map.files.length === 0) {
        ctx.ui.notify(
          "No recognizable source files found under this directory.",
          "warning",
        );
        return;
      }

      let prompt: string;
      if (sub === "explain") {
        prompt = explainPrompt(target, renderExplain(map, target));
      } else {
        const { text, truncated } = renderOverview(map);
        if (truncated) {
          ctx.ui.notify(
            "Codebase is large — the map was truncated. The agent can still read files directly.",
            "info",
          );
        }
        prompt = overviewPrompt(text, sub as "summary" | "overview");
      }

      // Hand the grounded prompt to the pi coding agent (triggers a turn).
      pi.sendUserMessage(prompt);
    },
  });
}
