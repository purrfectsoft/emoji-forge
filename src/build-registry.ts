#!/usr/bin/env node
/**
 * Build/validate central emoji registry.
 * - Writes emoji-forge/registry.json
 * - --check: compares and exits 1 if different (no write)
 */
import { readdirSync, readFileSync, writeFileSync, statSync } from "node:fs";
import { join } from "node:path";
import process from "node:process";

type Entry = {
  index: string;
  slug: string;
  display_name: string;
  path: string;
  file_hires: string;
  file_transparent: string;
  file_discord: string;
  category?: string;
  planet?: string;
  palette?: string[];
  date_forged?: string;
};

const ROOT = "emoji-forge";
const CHECK = process.argv.includes("--check");

function isDir(p: string) {
  try {
    return statSync(p).isDirectory();
  } catch {
    return false;
  }
}
function readJSON<T>(p: string): T {
  return JSON.parse(readFileSync(p, "utf8"));
}

function collect(): Entry[] {
  const out: Entry[] = [];
  const indexes = readdirSync(ROOT)
    .filter((d) => /^\d{3}$/.test(d))
    .sort();
  for (const idx of indexes) {
    const idxPath = join(ROOT, idx);
    if (!isDir(idxPath)) continue;
    const slugs = readdirSync(idxPath)
      .filter((d) => isDir(join(idxPath, d)))
      .sort();
    for (const slug of slugs) {
      const base = join(idxPath, slug);
      const metaPath = join(base, "metadata.json");
      let meta: any = {};
      try {
        meta = readJSON(metaPath);
      } catch {
        /* partial dir */
      }

      const display = meta.display_name ?? slug;
      const file_hires = `purr_${slug}_hires.png`;
      const file_transparent = `purr_${slug}_transparent.png`;
      const file_discord = `purr_${slug}.png`;

      out.push({
        index: idx,
        slug,
        display_name: display,
        path: base,
        file_hires,
        file_transparent,
        file_discord,
        category: meta.category,
        planet: meta.planet,
        palette: meta.palette,
        date_forged: meta.date_forged,
      });
    }
  }
  return out.sort((a, b) => (a.index + a.slug).localeCompare(b.index + b.slug));
}

function stableStringify(x: unknown) {
  return JSON.stringify(x, null, 2) + "\n";
}

const entries = collect();
const outPath = join(ROOT, "registry.json");
const nextJSON = stableStringify(entries);

if (CHECK) {
  try {
    const curr = readFileSync(outPath, "utf8");
    if (curr !== nextJSON) {
      console.error("Registry is out of date.");
      process.exit(1);
    }
    process.exit(0);
  } catch {
    console.error("Registry file missing.");
    process.exit(1);
  }
} else {
  writeFileSync(outPath, nextJSON, "utf8");
  console.log(`✅ Wrote ${outPath} (${entries.length} emojis)`);
}
