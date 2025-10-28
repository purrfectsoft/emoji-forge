#!/usr/bin/env node
/**
 * Purrfect Emoji Forge – Folder Template Generator (v2.1, TS + ESM)
 * yarn forge 002 ts "TypeScript" --category "Engineering - Languages"
 */
import { mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import process from "node:process";

type ParsedArgs = { _: string[]; [k: string]: string | boolean | string[] };

function parseArgs(argv: string[]): ParsedArgs {
  const out: ParsedArgs = { _: [] };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a.startsWith("--")) {
      const [rawK, rawV] = a.includes("=") ? a.split("=") : [a, argv[i + 1]];
      const key = rawK.replace(/^--/, "");
      if (!a.includes("=") && rawV && !rawV.startsWith("--")) {
        out[key] = rawV;
        i++;
      } else {
        out[key] = rawV && rawV !== rawK ? rawV : true;
      }
    } else {
      out._.push(a);
    }
  }
  return out;
}

const args = parseArgs(process.argv);
const [indexRaw, slugRaw, displayNameRaw] = args._;

if (!indexRaw || !slugRaw || !displayNameRaw) {
  console.error(
    'Usage: yarn forge <index> <slug> "<Display Name>" [--category "..."] [--planet "..."] [--palette "#a,#b,#c"]'
  );
  process.exit(1);
}

const index = String(indexRaw).padStart(3, "0");
const slug = String(slugRaw)
  .toLowerCase()
  .replace(/[^a-z0-9_-]/g, "");
const displayName = String(displayNameRaw);

const category = (args["category"] as string) || "Engineering - Languages";
const planet = (args["planet"] as string) || "Purrfect Software Limited";
const palette = ((args["palette"] as string) || "#f7df1e,#d2691e,#228b22,#1f77b4")
  .split(",")
  .map((s) => s.trim())
  .filter(Boolean);

const now = new Date();
const dateForged = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-${String(now.getDate()).padStart(2, "0")}`;

const baseDir = join("emoji-forge", index, slug);
const fileHires = `purr_${slug}_hires.png`;
const fileDiscord = `purr_${slug}.png`;

mkdirSync(baseDir, { recursive: true });

const docsMd = `# ${displayName} — Emoji Forge #${index} — :${slug}:

**Filename:** \`${fileDiscord}\`  
**Category:** ${category}  
**Planet:** ${planet}  

---

## 💡 Core Meaning & Emotion
Describe the identity, tone, and spirit of \`${displayName}\`.

---

## 🎨 Design Philosophy
- **Form:** Slightly tilted rhombus / irregular quad; disciplined asymmetry (< 10°)
- **Base:** Primary color per emoji
- **Symbol:** Core mark (letters/glyph), bold and readable
- **Feline Signature:** minimal paw/tail motif (optional)
- **Accent Palette:**  
${palette.map((p) => `  - \`${p}\``).join("\n")}
- **Background (Chroma Key):** Render on **solid \`#00FF43\`**. The pipeline converts this to **true transparency**.
- **Output Goal:** Discord-ready 128×128 transparent PNG + hi‑res archival

---

## 🧱 File Contents
| File | Purpose |
|------|--------|
| \`prompt.md\` | Gemini generation instructions (chroma key) |
| \`metadata.json\` | Registry entry |
| \`${fileHires}\` | Hi‑res export from Gemini (on \`#00FF43\`) |
| \`${fileDiscord}\` | Resized Discord version (128×128, transparent) |
`;

const promptMd = `# Gemini Generation Prompt — Purrfect Universe Emoji #${index} (:${slug}:)

**Prompt Title:** Purrfect Universe Emoji – ${displayName}

Create a **flat, vector emoji-style icon** representing **${displayName}** in the **Purrfect Universe** visual language.

---

## Concept & Mood
Confidently imperfect — dynamic yet stable; human yet precise.

---

## Visual Style
- **Overall Form:** Slightly irregular quadrilateral (e.g., softly tilted square / controlled rhombus). Tilt under 10°. Must read as a logo block.
- **Base Color:** Use the canonical base hue for this emoji (see docs).
- **Symbol:** Bold, clean core mark for **${displayName}**. No outlines, no gradients.
- **Feline Accent:** One minimal paw or tail cue; very subtle and integrated.
- **Accents (optional):**
${palette.map((p) => `  - \`${p}\``).join("\n")}
- **Style Guidelines:** Flat vector only; no shadows/bevels/glows; clean edges; slight asymmetry allowed.

---

## Background (Chroma Key)
Render on **pure solid \`#00FF43\`**. Do **not** use this color elsewhere; the pipeline replaces it with real transparency.

---

## Output Expectations
- Export a single **PNG** on \`#00FF43\` background.
- Square canvas, centered composition, slight padding.
`;

const metadata = {
  emoji_name: slug,
  display_name: displayName,
  index,
  category,
  planet,
  keywords: [slug, displayName.toLowerCase(), "purrfect", "emoji", "catpaw", "chroma"],
  palette,
  style: "flat",
  aspect_ratio: "1:1",
  background: "#00FF43",
  symbol: "DEFINE",
  easter_egg: "optional feline motif",
  file_hires: fileHires,
  file_discord: fileDiscord,
  authors: ["Arafat Zahan", "GPT-5"],
  supervised_by: "Misty, Keeper of Wisdom",
  date_forged: dateForged,
};

writeFileSync(join(baseDir, "docs.md"), docsMd, "utf8");
writeFileSync(join(baseDir, "prompt.md"), promptMd, "utf8");
writeFileSync(join(baseDir, "metadata.json"), JSON.stringify(metadata, null, 2), "utf8");

console.log(`✅ Forged: ${baseDir}`);
console.log(`   - docs.md`);
console.log(`   - prompt.md`);
console.log(`   - metadata.json`);
console.log(
  `Next: export ${fileHires} with chroma (#00FF43), then: yarn resize -- ${index}/${slug}`
);
