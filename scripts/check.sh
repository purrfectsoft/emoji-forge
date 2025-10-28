#!/usr/bin/env bash
# ==============================================
#  Purrfect Emoji Forge - Check Utility (v1.3)
#  1) Ensures every emoji dir is COMPLETE (no partials)
#  2) Ensures there are NO EXTRA ARTIFACTS in emoji dirs
#  3) Ensures a central registry exists and includes all emojis
#     (uses `yarn build:registry --check` if available)
# ==============================================

[ -z "$BASH_VERSION" ] && exec bash "$0" "$@"
set -euo pipefail

ROOT="emoji-forge"
missing=0

# ImageMagick detect
if command -v magick &>/dev/null; then IM="magick"
elif command -v identify &>/dev/null; then IM="identify"
else
  echo "❌ ImageMagick not found. Install it (brew install imagemagick / apt install imagemagick)."
  exit 1
fi

# helpers
has_alpha () { $IM identify -format "%[channels]" "$1" 2>/dev/null | grep -qi "alpha"; }
has_transparency () {
  local opaque
  opaque=$($IM identify -format "%[opaque]" "$1" 2>/dev/null || echo "Unknown")
  [[ "$opaque" == "False" || "$opaque" == "false" ]]
}

echo "🔎 Checking emoji forge integrity..."
echo

# collect all dirs
mapfile -t DIRS < <(find "$ROOT" -mindepth 2 -maxdepth 2 -type d | sort)

if [[ ${#DIRS[@]} -eq 0 ]]; then
  echo "ℹ️  No emoji directories under $ROOT/*/*"
  exit 0
fi

ALL_KEYS=()   # for registry cross-check

for dir in "${DIRS[@]}"; do
  idx=$(basename "$(dirname "$dir")")
  slug=$(basename "$dir")
  rel="$ROOT/$idx/$slug"

  docs="$rel/docs.md"
  prompt="$rel/prompt.md"
  meta="$rel/metadata.json"
  hires="$rel/purr_${slug}_hires.png"
  trans="$rel/purr_${slug}_transparent.png"
  out="$rel/purr_${slug}.png"

  # Allowed file list (exact)
  declare -A ALLOWED=()
  ALLOWED["$docs"]=1
  ALLOWED["$prompt"]=1
  ALLOWED["$meta"]=1
  ALLOWED["$hires"]=1
  ALLOWED["$trans"]=1
  ALLOWED["$out"]=1

  issues=()

  # 1) Completeness (no partial)
  [[ -f "$docs"   ]] || issues+=("missing docs.md")
  [[ -f "$prompt" ]] || issues+=("missing prompt.md")
  [[ -f "$meta"   ]] || issues+=("missing metadata.json")
  [[ -f "$hires"  ]] || issues+=("missing purr_${slug}_hires.png")
  [[ -f "$trans"  ]] || issues+=("missing purr_${slug}_transparent.png (run yarn resize)")
  [[ -f "$out"    ]] || issues+=("missing purr_${slug}.png (run yarn resize)")

  # 2) Transparency checks on outputs
  if [[ -f "$trans" ]]; then
    has_alpha "$trans" || issues+=("purr_${slug}_transparent.png: no alpha channel")
    has_transparency "$trans" || issues+=("purr_${slug}_transparent.png: not actually transparent")
  fi
  if [[ -f "$out" ]]; then
    has_alpha "$out" || issues+=("purr_${slug}.png: no alpha channel")
    has_transparency "$out" || issues+=("purr_${slug}.png: not actually transparent")
  fi

  # 3) No extra artifacts
  while IFS= read -r -d '' f; do
    # allow hidden OS junk — we still flag them
    if [[ -z "${ALLOWED[$f]+x}" ]]; then
      base=$(basename "$f")
      if [[ "$base" == ".DS_Store" || "$base" == "Thumbs.db" ]]; then
        issues+=("extra artifact: $base (please delete)")
      else
        issues+=("extra artifact: $(basename "$f")")
      fi
    fi
  done < <(find "$rel" -type f -print0)

  # output
  if [[ ${#issues[@]} -eq 0 ]]; then
    echo "✅ $rel"
  else
    echo "⚠️  $rel"
    for i in "${issues[@]}"; do echo "   - $i"; done
    missing=1
  fi

  ALL_KEYS+=("${idx}/${slug}")
done

echo
# 4) Central registry check (uses TS generator with --check)
if [[ -f "src/build-registry.ts" ]]; then
  echo "📚 Validating central registry via: yarn build:registry --check"
  if yarn -s build:registry --check >/dev/null; then
    echo "✅ Registry OK"
  else
    echo "❌ Registry mismatch — run: yarn build:registry"
    missing=1
  fi
else
  echo "ℹ️  No registry generator found (src/build-registry.ts)."
fi

echo
if [[ $missing -eq 0 ]]; then
  echo "🎉 All good!"
else
  echo "🧭 Fix tips:"
  echo " - Forge:  yarn forge <index> <slug> \"Display Name\""
  echo " - Export: hi-res on solid #00FF43"
  echo " - Resize: yarn resize -- <index>/<slug>"
  echo " - Registry: yarn build:registry"
  exit 1
fi
