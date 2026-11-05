/**
 * OSC 7501 status reporting for pi and pi-permission-system.
 *
 * Reports working/blocked/done to terminals that support OSC 7501, so they can
 * notify you when a permission prompt is waiting. Other terminals ignore the
 * sequence. Permission rules live in pi-permission-system's config.json; this
 * extension only observes its prompts and never gates anything itself.
 *
 * In tmux, status needs `set -g allow-passthrough on`.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const APP = "pi";
const MAX_MSG_LENGTH = 200;

function redact(text: string): string {
  return text
    .replace(/(--?(token|password|secret|api[-_]?key)[= ])\S+/gi, "$1***")
    .replace(/(Authorization:\s*)\S+(\s+[^\s"']+)?/gi, "$1***")
    .replace(/\b([A-Z0-9_]*(KEY|TOKEN|SECRET|PASSWORD)[A-Z0-9_]*=)\S+/gi, "$1***")
    .replace(/\/\/[^/\s@]+@/g, "//***@");
}

function status(state: string, fields: { kind?: string; msg?: string } = {}): void {
  // Piped stdout carries print/json/rpc output, which escape codes would corrupt.
  if (!process.stdout.isTTY) return;
  try {
    let body = `state=${state}`;
    if (fields.kind) body += `:kind=${fields.kind}`;
    body += `:app=${APP}`;
    if (fields.msg) {
      const line = redact(fields.msg).replace(/\s*[\r\n]+\s*/g, " ").slice(0, MAX_MSG_LENGTH);
      body += `:msg=${Buffer.from(line, "utf8").toString("base64")}`;
    }
    let sequence = `\x1b]7501;${body}\x1b\\`;
    if (process.env.TMUX) {
      sequence = `\x1bPtmux;${sequence.replaceAll("\x1b", "\x1b\x1b")}\x1b\\`;
    }
    process.stdout.write(sequence);
  } catch {
    // Status reporting is best-effort.
  }
}

export default function (pi: ExtensionAPI) {
  // Several prompts can be pending at once (queued, or forwarded from subagents).
  const openPrompts = new Set<string>();
  let running = false;

  const reportCurrent = () => {
    if (running) status("working");
    else status("done", { msg: "Agent finished" });
  };

  pi.on("agent_start", () => {
    running = true;
    if (openPrompts.size === 0) status("working");
  });

  // agent_end can be followed by retries or queued messages; agent_settled is final.
  pi.on("agent_settled", () => {
    running = false;
    if (openPrompts.size === 0) reportCurrent();
  });

  pi.on("session_shutdown", () => {
    unsubscribePrompt();
    unsubscribeDecision();
    openPrompts.clear();
    status("clear");
  });

  const unsubscribePrompt = pi.events.on("permissions:ui_prompt", (raw) => {
    const { requestId, surface, value } = raw as {
      requestId: string;
      surface?: string | null;
      value?: string | null;
    };
    openPrompts.add(requestId);
    const target = [surface, value].filter((part) => typeof part === "string").join(": ");
    status("blocked", { kind: "permission", msg: target ? `Allow ${target}` : "Permission required" });
  });

  const unsubscribeDecision = pi.events.on("permissions:decision", (raw) => {
    const { requestId } = raw as { requestId: string };
    // Most decisions resolve by policy and never prompted.
    if (!openPrompts.delete(requestId)) return;
    if (openPrompts.size === 0) reportCurrent();
  });
}
