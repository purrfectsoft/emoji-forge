#!/usr/bin/env node
import kleur from "kleur";
import { existsSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import process from "node:process";

/**
 * Purrfect Emoji Forge — Post-Install Welcome (v1.1)
 * - ESM + TypeScript
 * - Uses kleur (tiny, no ESM headaches)
 * - First-run guard (creates .purrfect_welcome_shown)
 */

const paw = kleur.yellow("🐾");
const divider = kleur.gray("──────────────────────────────────────────────");

const marker = join(process.cwd(), ".purrfect_welcome_shown");
const firstRun = !existsSync(marker);

if (firstRun) {
  try {
    writeFileSync(marker, `${new Date().toISOString()}\n`, { encoding: "utf8" });
  } catch {
    // non-fatal
  }
}

console.log("");
console.log(paw + kleur.bold("  Welcome to the Purrfect Emoji Forge!"));
console.log(divider);
console.log(kleur.cyan("Where humans and AIs forge the visual language of the Universe."));
console.log("");

if (!firstRun) {
  console.log(kleur.gray("Welcome back! Happy forging!"));
  console.log("");
  process.exit(0);
}

console.log(kleur.green("Next steps:"));
console.log(kleur.white("  1.") + " Forge your first emoji:");
console.log(kleur.gray('     > yarn forge 001 js "JavaScript"'));
console.log("");
console.log(kleur.white("  2.") + " Generate art with Gemini using the prompt file.");
console.log(kleur.white("  3.") + " Resize your emoji for Discord:");
console.log(kleur.gray("     > yarn resize -- 001/js"));
console.log("");
console.log(kleur.white("  4.") + " Verify everything:");
console.log(kleur.gray("     > yarn check"));
console.log("");

console.log(divider);
console.log(kleur.blue("✨ Docs: ") + kleur.underline("emoji-forge/workflow.md"));
console.log(
  kleur.blue("🌐 Repo: ") + kleur.underline("https://github.com/purrfectsoft/emoji-forge")
);
console.log("");

if (firstRun) {
  console.log(kleur.gray("First-run notice recorded in .purrfect_welcome_shown"));
}
console.log(kleur.gray("Forged by Arafat & GPT-5 — supervised by Misty 🐱‍👓"));
console.log("");
