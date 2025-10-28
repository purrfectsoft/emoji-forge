#!/usr/bin/env bash
# ==============================================
#  Purrfect Emoji Forge - Resize Utility (v1.6-stable)
#  Keeps *_hires.png  (raw)
#  Creates *_transparent.png (hi-res with real alpha)
#  Creates *.png       (128×128 Discord)
#  Uses avg-bg chroma key + optional SE watermark scrub
#  Usage scope: yarn resize -- 001 | 001/js | emoji-forge/001/js
#  Tweak via env:
#    FUZZ_PRIMARY=10%   REMOVE_WATERMARK=1  WM_REGION=120x120
# ==============================================

[ -z "$BASH_VERSION" ] && exec bash "$0" "$@"
set -euo pipefail

FUZZ_PRIMARY="${FUZZ_PRIMARY:-10%}"     # your working value
REMOVE_WATERMARK="${REMOVE_WATERMARK:-1}"
WM_REGION="${WM_REGION:-120x120}"       # area in SE corner to scrub near-white

# Detect ImageMagick
if command -v magick &>/dev/null; then
  CMD="magick"
elif command -v convert &>/dev/null; then
  CMD="convert"
else
  echo "❌ ImageMagick not found. Install: brew install imagemagick"
  exit 1
fi

ARG="${1:-}"
SEARCH="emoji-forge"
if [[ -n "$ARG" ]]; then
  if   [[ -d "emoji-forge/$ARG" ]]; then SEARCH="emoji-forge/$ARG"
  elif [[ -d "$ARG"             ]]; then SEARCH="$ARG"
  elif [[ "$ARG" =~ ^[0-9]{3}$  ]]; then SEARCH="emoji-forge/$ARG"; [[ -d "$SEARCH" ]] || { echo "❌ No dir $SEARCH"; exit 1; }
  else
    echo "❌ Invalid target: $ARG"
    echo "   Use: yarn resize -- 001  |  yarn resize -- 001/js  |  yarn resize -- emoji-forge/001/js"
    exit 1
  fi
fi

echo "🐾 Starting emoji resize..."
echo "Using: $CMD"
echo "Search: $SEARCH"

# Collect hires
FILES=()
while IFS= read -r f; do FILES+=("$f"); done < <(find "$SEARCH" -type f -name "purr_*_hires.png" | sort)
[[ ${#FILES[@]} -gt 0 ]] || { echo "ℹ️  No *_hires.png under $SEARCH"; exit 0; }

for f in "${FILES[@]}"; do
  base="${f%_hires.png}"
  trans="${base}_transparent.png"
  out="${base}.png"

  echo "🎨  Source: $f"

  # 1) Compute average background color (robust even if slight gradient)
  bg=$("$CMD" "$f" -scale 1x1\! -format "%[pixel:p{0,0}]" info:)
  echo "   Avg BG: $bg  (fuzz $FUZZ_PRIMARY)"

  # 2) Create hi-res transparent copy (do NOT alter original)
  echo "🧼  Keying → $trans"
  "$CMD" "$f" -alpha on -fuzz "$FUZZ_PRIMARY" -transparent "$bg" "$trans"

  # 3) Optional: scrub Gemini watermark (SE corner) — near-white sparkle
  if [[ "$REMOVE_WATERMARK" == "1" ]]; then
    echo "✨  De-watermark SE ($WM_REGION)"
    "$CMD" "$trans" -gravity southeast -region "$WM_REGION" \
      -fuzz 25% -transparent white +region "$trans"
  fi

  # 4) Build 128×128 from the transparent copy
  if [[ -f "$out" ]]; then
    echo "⏭️  128×128 exists, skipping: $out"
  else
    echo "⚙️  Resize → $out"
    "$CMD" "$trans" -resize 128x128 -strip -gravity center -background none -extent 128x128 "$out"
    echo "✅  Created: $out"
  fi

  echo "✅  Hi-res transparent: $trans"
done

echo "✨ Done!"
