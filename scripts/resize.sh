#!/usr/bin/env bash
# ==============================================
#  Purrfect Emoji Forge - Resize Utility (v1.9.1)
#  0) Detect bg color
#  1) Neutralize SE watermark (repaint near-white → bg)
#  2) Key out bg → *_transparent.png (hi-res alpha)
#  3) Optional trim + safety pad
#  4) Fit/center to 128×128 → final *.png
#
#  Keeps: *_hires.png
#  Creates: *_neutral.png, *_transparent.png, *.png
#
#  Env knobs:
#    FUZZ_PRIMARY=10%  WM_K=0.14  WM_FUZZ=35%
#    EDGE_TRIM=1  TRIM_FUZZ=2%  PAD=4  FIT_SIZE=128
#    DEBUG=1  # bash xtrace
# ==============================================

[ -z "$BASH_VERSION" ] && exec bash "$0" "$@"
set -euo pipefail

# Debug + error trap
[[ "${DEBUG:-0}" == "1" ]] && set -x
trap 'echo "❌ Error on line $LINENO: ${BASH_COMMAND}" >&2' ERR

# --- knobs ---
FUZZ_PRIMARY="${FUZZ_PRIMARY:-10%}"
WM_K="${WM_K:-0.14}"
WM_FUZZ="${WM_FUZZ:-35%}"
EDGE_TRIM="${EDGE_TRIM:-1}"
TRIM_FUZZ="${TRIM_FUZZ:-2%}"
PAD="${PAD:-4}"
FIT_SIZE="${FIT_SIZE:-128}"

# Detect ImageMagick (v7 preferred)
if command -v magick &>/dev/null; then
  CMD="magick"
elif command -v convert &>/dev/null; then
  CMD="convert"
else
  echo "❌ ImageMagick not found. Install: brew install imagemagick / apt install imagemagick"
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
echo "Neutralize: WM_K=$WM_K  WM_FUZZ=$WM_FUZZ   |   Key: FUZZ_PRIMARY=$FUZZ_PRIMARY"
echo "Trim: EDGE_TRIM=$EDGE_TRIM  TRIM_FUZZ=$TRIM_FUZZ  PAD=${PAD}px   |   Fit: ${FIT_SIZE}px"

# Collect hires
FILES=()
while IFS= read -r f; do FILES+=("$f"); done < <(find "$SEARCH" -type f -name "purr_*_hires.png" | sort)
[[ ${#FILES[@]} -gt 0 ]] || { echo "ℹ️  No *_hires.png under $SEARCH"; exit 0; }

for f in "${FILES[@]}"; do
  base="${f%_hires.png}"
  neutral="${base}_neutral.png"
  trans="${base}_transparent.png"
  out="${base}.png"

  echo ""
  echo "🎨  Source: $f"

  # 0) Avg background color (from top-left)
  bg=$("$CMD" "$f" -scale 1x1\! -format "%[pixel:p{0,0}]" info:)
  [[ -n "$bg" ]] || { echo "❌ Could not sample background color"; exit 1; }
  echo "   Avg BG: $bg  (key fuzz $FUZZ_PRIMARY)"

  # Image size for region calc (use magick identify explicitly)
  WH=$("$CMD" identify -format "%w %h" "$f")
  read -r W H <<<"$WH"
  [[ -n "${W:-}" && -n "${H:-}" ]] || { echo "❌ Could not read image size"; exit 1; }
  echo "   Size: ${W}x${H}"

  # region side = round(min(W,H) * WM_K)
  region=$(
    awk -v w="$W" -v h="$H" -v k="$WM_K" 'BEGIN{
      s=int((w<h?w:h)*k + 0.5);
      if (s<32) s=32;  # clamp tiny images
      printf "%dx%d", s, s;
    }'
  )
  echo "   SE neutralize region: $region (WM_FUZZ $WM_FUZZ)"

  # 1) Neutralize watermark (SE square): repaint near-white to exact bg color
  echo "🛡️   Neutralizing SE star → bg color: $neutral"
  "$CMD" "$f" \
    -gravity southeast -region "$region" \
    -fuzz "$WM_FUZZ" -fill "$bg" -opaque white +region \
    PNG32:"$neutral"

  # 2) Key out background → hi-res transparent
  echo "🧼  Keying bg → transparency: $trans"
  "$CMD" "$neutral" -alpha on -fuzz "$FUZZ_PRIMARY" -transparent "$bg" PNG32:"$trans"

  # 3) Optional trim + pad
  work="$trans"
  if [[ "$EDGE_TRIM" == "1" ]]; then
    echo "✂️   Trim + pad (TRIM_FUZZ $TRIM_FUZZ, PAD ${PAD}px)"
    "$CMD" "$trans" \
      -alpha on -fuzz "$TRIM_FUZZ" -trim +repage \
      -bordercolor none -border "$PAD" \
      PNG32:"$trans"
    work="$trans"
  fi

  # 4) Fit/center to square
  if [[ -f "$out" ]]; then
    echo "⏭️  Final exists, skipping: $out"
  else
    echo "⚙️  Fit/center → $out"
    "$CMD" "$work" \
      -resize "${FIT_SIZE}x${FIT_SIZE}" \
      -strip -background none -gravity center -extent "${FIT_SIZE}x${FIT_SIZE}" \
      PNG32:"$out"
    echo "✅  Created: $out"
  fi

  echo "✅  Hi-res transparent: $trans"
done

echo ""
echo "✨ Done!"
