/**
 * /context — Visualize current context usage as a colored bar.
 *
 * Shows a bar of colored segments representing token usage, broken down by:
 * - System prompt, User messages, Assistant text, Thinking
 * - Tool results (per tool), Compaction summaries, Custom messages, Images
 * - Free space
 *
 * Also shows cache stats and optimization suggestions.
 */

import type {
  ExtensionAPI,
  ExtensionCommandContext,
  ContextUsage,
  Theme,
} from "@earendil-works/pi-coding-agent";
import type {
  AssistantMessage,
  ToolResultMessage,
  UserMessage,
} from "@earendil-works/pi-ai";
import { matchesKey, visibleWidth } from "@earendil-works/pi-tui";

// ── Category definitions ──────────────────────────────────────────────

interface Category {
  key: string;
  label: string;
  tokens: number;
  color: (theme: Theme, text: string) => string;
  bar: string; // Colored bar segment character
}

const ansi256Fg = (code: number, text: string) =>
  `\x1b[38;5;${code}m${text}\x1b[0m`;
const ansi256Bg = (code: number, text: string) =>
  `\x1b[48;5;${code}m${text}\x1b[0m`;

// ── Deterministic color from tool name ────────────────────────────────

function colorForTool(name: string): number {
  let hash = 5381;
  for (let i = 0; i < name.length; i++) {
    hash = (hash << 5) + hash + name.charCodeAt(i);
  }
  return 16 + (Math.abs(hash) % 240); // skip dark ANSI colors
}

// ── Token estimation ──────────────────────────────────────────────────

function estimateTokens(
  content: string | Array<{ type: string; [k: string]: any }>,
): number {
  if (typeof content === "string") return Math.ceil(content.length / 4);
  let total = 0;
  for (const block of content) {
    if (block.type === "text")
      total += Math.ceil((block.text ?? "").length / 4);
    else if (block.type === "image") total += 1600;
  }
  return total;
}

// ── Breakdown computation ─────────────────────────────────────────────

interface ContextBreakdown {
  categories: Category[];
  totalTokens: number;
  contextWindow: number;
  percent: number | null;
  cacheRead: number;
  cacheWrite: number;
  totalCost: number;
  messageCount: number;
  turnCount: number;
}

// Known category label + color config
const CAT_CONFIG: Record<string, { label: string; color: number }> = {
  system: { label: "System Prompt", color: 141 },
  user: { label: "User Messages", color: 75 },
  assistant: { label: "Assistant Text", color: 114 },
  thinking: { label: "Thinking", color: 216 },
  compaction: { label: "Compaction", color: 245 },
  custom: { label: "Custom Messages", color: 183 },
  images: { label: "Images", color: 219 },
};

function computeBreakdown(ctx: any): ContextBreakdown | null {
  const usage: ContextUsage | undefined = ctx.getContextUsage();
  if (!usage) return null;

  const { contextWindow } = usage;
  const branch = ctx.sessionManager.getBranch();

  const catTokens: Record<string, number> = {};
  let cacheRead = 0,
    cacheWrite = 0,
    totalCost = 0;
  let turnCount = 0,
    messageCount = 0;

  // System prompt
  try {
    const sys = ctx.getSystemPrompt();
    if (sys) catTokens.system = estimateTokens(sys);
  } catch {
    /* not available outside a turn */
  }

  for (const entry of branch) {
    if (entry.type === "compaction" || entry.type === "branch_summary") {
      catTokens.compaction =
        (catTokens.compaction ?? 0) + estimateTokens(entry.summary ?? "");
      continue;
    }
    if (entry.type === "custom_message") {
      catTokens.custom =
        (catTokens.custom ?? 0) + estimateTokens(entry.content);
      continue;
    }
    if (entry.type !== "message") continue;

    const msg = entry.message;
    messageCount++;

    if (msg.role === "user") {
      const um = msg as UserMessage;
      if (typeof um.content === "string") {
        catTokens.user = (catTokens.user ?? 0) + estimateTokens(um.content);
      } else if (Array.isArray(um.content)) {
        for (const block of um.content) {
          if (block.type === "text")
            catTokens.user = (catTokens.user ?? 0) + estimateTokens(block.text);
          else if (block.type === "image")
            catTokens.images = (catTokens.images ?? 0) + 1600;
        }
      }
    } else if (msg.role === "assistant") {
      const am = msg as AssistantMessage;
      turnCount++;
      cacheRead += am.usage.cacheRead;
      cacheWrite += am.usage.cacheWrite;
      totalCost += am.usage.cost.total;

      for (const block of am.content) {
        if (block.type === "text")
          catTokens.assistant =
            (catTokens.assistant ?? 0) + estimateTokens(block.text);
        else if (block.type === "thinking")
          catTokens.thinking =
            (catTokens.thinking ?? 0) + estimateTokens(block.thinking);
        if ((block as any).type === "tool_use" || (block as any).toolCallId) {
          catTokens.assistant =
            (catTokens.assistant ?? 0) +
            estimateTokens(JSON.stringify((block as any).arguments ?? {}));
        }
      }
    } else if (msg.role === "toolResult") {
      const tr = msg as ToolResultMessage;
      catTokens[`tool:${tr.toolName || "unknown"}`] =
        (catTokens[`tool:${tr.toolName || "unknown"}`] ?? 0) +
        estimateTokens(tr.content);
    }
  }

  // Use SDK total when available; fall back to summed estimates
  const totalTokens =
    usage.tokens ?? Object.values(catTokens).reduce((a, b) => a + b, 0);
  const freeTokens = Math.max(0, contextWindow - totalTokens);

  // Build ordered category list
  const categories: Category[] = [];

  const addCat = (key: string, tokens: number) => {
    if (tokens <= 0) return;
    const cfg = CAT_CONFIG[key];
    if (cfg) {
      categories.push({
        key,
        label: cfg.label,
        tokens,
        color: (_th, text) => ansi256Fg(cfg.color, text),
        bar: ansi256Bg(cfg.color, " "),
      });
    }
  };

  // Ordered: known categories first, then tools sorted by size, then rest
  for (const key of ["system", "user", "assistant", "thinking"])
    addCat(key, catTokens[key] ?? 0);

  // Tool categories — descending by tokens
  const toolKeys = Object.keys(catTokens)
    .filter((k) => k.startsWith("tool:"))
    .sort((a, b) => catTokens[b]! - catTokens[a]!);
  for (const key of toolKeys) {
    const name = key.slice(5);
    const col = colorForTool(name);
    categories.push({
      key,
      label: `Tool: ${name}`,
      tokens: catTokens[key]!,
      color: (_th, text) => ansi256Fg(col, text),
      bar: ansi256Bg(col, " "),
    });
  }

  for (const key of ["compaction", "custom", "images"])
    addCat(key, catTokens[key] ?? 0);

  // Free space
  categories.push({
    key: "free",
    label: "Free",
    tokens: freeTokens,
    color: (_th, text) => ansi256Fg(240, text),
    bar: ansi256Bg(236, " "),
  });

  return {
    categories,
    totalTokens,
    contextWindow,
    percent: usage.percent,
    cacheRead,
    cacheWrite,
    totalCost,
    messageCount,
    turnCount,
  };
}

// ── Bar rendering ─────────────────────────────────────────────────────

function renderBar(breakdown: ContextBreakdown, width: number): string {
  const barW = Math.max(10, width - 14); // room for `[` + bar + `]` + ` 99.9%`
  if (barW <= 0) return "";

  let bar = "";
  let remaining = barW;

  for (const cat of breakdown.categories) {
    if (cat.tokens <= 0) continue;
    const cells = Math.max(
      1,
      Math.round((cat.tokens / breakdown.contextWindow) * barW),
    );
    const use = Math.min(cells, remaining);
    bar += cat.bar.repeat(use);
    remaining -= use;
    if (remaining <= 0) break;
  }
  if (remaining > 0) {
    const freeCat = breakdown.categories.find((c) => c.key === "free");
    bar += (freeCat?.bar ?? ansi256Bg(236, " ")).repeat(remaining);
  }

  const pct =
    breakdown.percent !== null ? ` ${breakdown.percent.toFixed(1)}%` : "";
  return `[${bar}]${pct}`;
}

// ── Formatting ────────────────────────────────────────────────────────

function formatTokens(n: number): string {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`;
  if (n >= 1_000) return `${(n / 1_000).toFixed(1)}k`;
  return `${n}`;
}

function buildOverlay(
  breakdown: ContextBreakdown,
  theme: Theme,
  width: number,
): string[] {
  const lines: string[] = [];
  const innerW = width - 2;

  const pad = (s: string, len: number) =>
    s + " ".repeat(Math.max(0, len - visibleWidth(s)));
  const row = (content: string) =>
    theme.fg("border", "│") +
    pad(` ${content}`, innerW) +
    theme.fg("border", "│");
  const hr = () =>
    theme.fg("border", "│") +
    theme.fg("dim", "─".repeat(innerW)) +
    theme.fg("border", "│");

  // Top
  lines.push(theme.fg("border", `╭${"─".repeat(innerW)}╮`));

  // Title
  const pct =
    breakdown.percent !== null ? ` (${breakdown.percent.toFixed(1)}%)` : "";
  lines.push(row(theme.bold(theme.fg("accent", `Context Window Usage${pct}`))));
  lines.push(
    row(
      theme.fg(
        "muted",
        `${formatTokens(breakdown.totalTokens)} / ${formatTokens(breakdown.contextWindow)} tokens`,
      ),
    ),
  );

  // Bar
  const barStr = renderBar(breakdown, innerW);
  if (barStr) lines.push(row(barStr));

  lines.push(hr());

  // Legend — one entry per line
  for (const cat of breakdown.categories) {
    if (cat.tokens <= 0) continue;
    const pctStr = ((cat.tokens / breakdown.contextWindow) * 100).toFixed(1);
    const entry = `${cat.bar} ${cat.color(theme, cat.label)} ${theme.fg("dim", `${formatTokens(cat.tokens)} (${pctStr}%)`)}`;
    lines.push(row(entry));
  }

  lines.push(hr());

  // Stats — one per line, no wrapping
  lines.push(row(theme.fg("accent", theme.bold("Session Stats"))));
  const stats = [
    `Turns: ${breakdown.turnCount}`,
    `Messages: ${breakdown.messageCount}`,
    `Cache read: ${formatTokens(breakdown.cacheRead)}`,
    `Cache write: ${formatTokens(breakdown.cacheWrite)}`,
    `Cost: $${breakdown.totalCost.toFixed(4)}`,
  ];
  for (const s of stats) {
    lines.push(row(theme.fg("muted", s)));
  }

  // Warnings
  const warnings: string[] = [];
  if (breakdown.percent !== null && breakdown.percent > 80) {
    warnings.push("⚠ Context above 80% — consider /compact");
  }
  if (breakdown.percent !== null && breakdown.percent > 95) {
    warnings.push("🔴 Near limit — compaction strongly recommended");
  }
  const biggestTool = breakdown.categories
    .filter((c) => c.key.startsWith("tool:"))
    .sort((a, b) => b.tokens - a.tokens)[0];
  if (biggestTool && biggestTool.tokens > breakdown.contextWindow * 0.2) {
    warnings.push(
      `💡 ${biggestTool.label} uses ${((biggestTool.tokens / breakdown.contextWindow) * 100).toFixed(0)}% of context`,
    );
  }
  if (warnings.length > 0) {
    lines.push(hr());
    for (const w of warnings) {
      lines.push(row(theme.fg("warning", w)));
    }
  }

  // Bottom
  lines.push(row(theme.fg("dim", "Press Escape to close")));
  lines.push(theme.fg("border", `╰${"─".repeat(innerW)}╯`));

  return lines;
}

// ── Extension entry point ─────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  pi.registerCommand("context", {
    description: "Visualize current context usage as a colored bar",
    handler: async (_args: string, ctx: ExtensionCommandContext) => {
      const breakdown = computeBreakdown(ctx);
      if (!breakdown) {
        ctx.ui.notify(
          "No context usage data available yet. Send a message first.",
          "warning",
        );
        return;
      }

      await ctx.ui.custom<void>(
        (_tui, theme, _keybindings, done) => {
          const cachedBreakdown = breakdown;
          return {
            handleInput(data: string) {
              if (
                matchesKey(data, "escape") ||
                matchesKey(data, "q") ||
                matchesKey(data, "return")
              ) {
                done(undefined);
              }
            },
            render(width: number): string[] {
              return buildOverlay(cachedBreakdown, theme, width);
            },
            invalidate() {},
          };
        },
        {
          overlay: true,
          overlayOptions: {
            anchor: "center",
            width: "80%",
            maxWidth: 100,
            minWidth: 40,
            maxHeight: "90%",
          },
        },
      );
    },
  });
}
