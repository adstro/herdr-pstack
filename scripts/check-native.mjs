#!/usr/bin/env node
// Fails while any Cursor-only plumbing term is left in the port's prose and shell scripts.
import { readFileSync, readdirSync, statSync } from "node:fs";
import { dirname, join, relative } from "node:path";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("..", import.meta.url));
const TERMS = {
  "Task tool": /\bTask\b/,
  AskQuestion: /\bAskQuestion\b/,
  subagent_type: /\bsubagent_type\b/,
  generalPurpose: /\bgeneralPurpose\b/,
  run_in_background: /\brun_in_background\b/,
  readonly: /\breadonly\b(?! __brand)/,
  ".cursor path": /\.cursor\b/,
  ".mdc rule": /\.mdc\b|\balwaysApply\b/,
  "cursor-team-kit": /\bcursor-team-kit\b/,
  Cursor: /\bCursor\b/,
  "cloud agent": /\bcloud agents?\b|environment: "cloud"/i,
  "model slug": /\b(claude-(opus|sonnet|haiku|fable)-[\d-]+-(low|medium|high|xhigh|max)|grok-[\d.]+-(low|medium|high|xhigh|max))\b|-fast\b|\bfast or standard speed\b|\bstandard speed\b/,
  Automations: /\bAutomations?\b|\bSendToUser\b|\bupdate_state\b/,
};
// Each line is `<path>\t<substring>`: a hit on a line of that file holding the substring is legitimate.
const allow = readFileSync(join(root, "scripts/native-allow.txt"), "utf8")
  .split("\n").filter((l) => l && !l.startsWith("#")).map((l) => l.split("\t"));

const walk = (dir) => readdirSync(dir).flatMap((name) => {
  const path = join(dir, name);
  if (name === ".git" || name === "node_modules" || name === ".verify") return [];
  return statSync(path).isDirectory() ? walk(path) : [path];
});

const hits = [];
for (const file of walk(root)) {
  const rel = relative(root, file);
  if (!/\.(md|sh)$|^plugin\.json$|\.claude-plugin\/plugin\.json$/.test(rel) || /^(scripts|\.claude)\//.test(rel) || rel === "PORTING.md") continue;
  readFileSync(file, "utf8").split("\n").forEach((line, i) => {
    for (const [term, re] of Object.entries(TERMS)) {
      if (!re.test(line)) continue;
      if (allow.some(([p, s]) => p === rel && line.includes(s))) continue;
      hits.push(`${rel}:${i + 1}\t${term}\t${line.trim().slice(0, 140)}`);
    }
  });
}
const slug = (h) => h.toLowerCase().replace(/[^\w\- ]/g, "").replace(/ /g, "-");
const anchors = (file) => new Set([...readFileSync(file, "utf8").matchAll(/^#+ (.*)$/gm)].map((m) => slug(m[1])));
for (const file of walk(root).filter((f) => f.endsWith(".md"))) {
  const rel = relative(root, file);
  for (const [, href] of readFileSync(file, "utf8").matchAll(/\]\(([^)\s]+)\)/g)) {
    if (/^[a-z]+:|^</.test(href) || (!href.startsWith("#") && !/[./]/.test(href))) continue;
    const [path, anchor] = href.split("#");
    const target = path ? join(dirname(file), decodeURI(path)) : file;
    let ok = true;
    try { statSync(target); } catch { ok = false; }
    if (ok && anchor && target.endsWith(".md") && !anchors(target).has(anchor)) ok = false;
    if (!ok) hits.push(`${rel}:0\tbroken link\t${href}`);
  }
}
const verbose = process.argv.includes("--list");
if (verbose) console.log(hits.join("\n"));
const byFile = Object.entries(hits.reduce((m, h) => ((m[h.split(":")[0]] = (m[h.split(":")[0]] ?? 0) + 1), m), {}));
if (!verbose) for (const [f, n] of byFile.sort((a, b) => b[1] - a[1])) console.log(`${String(n).padStart(4)} ${f}`);
console.log(`${hits.length} Cursor-only hits in ${byFile.length} files`);
process.exit(hits.length ? 1 : 0);
