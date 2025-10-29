#!/usr/bin/env bash
# ==============================================
#  Purrfect Emoji Forge - Clean Utility (v1.0)
#  Removes generated artifacts while keeping sources.
#
#  Removes:
#   - exports/* (Discord-ready bundle)
#   - purr_*_transparent.png (hi-res with alpha)
#   - purr_*.png (128×128), EXCEPT *_hires.png
#   - purr_*_transparent_cropped.png (if any)
#
#  Keeps:
#   - purr_*_hires.png
#   - all docs/prompt/metadata
#
#  Usage:
#    yarn clean                  # clean everything
#    yarn clean -- 003           # clean one index
#    yarn clean -- 003/html      # clean a subfolder
#    yarn clean -- exports       # only exports
#
#  Env:
#    DRY_RUN=1  # show what would be removed
# ==============================================

# Force bash even if invoked via sh
[ -z "${BASH_VERSION:-}" ] && exec bash "$0" "$@"
set -euo pipefail

ARG="${1:-}"
SCOPE="emoji-forge"
ONLY_EXPORTS=0
DRY="${DRY_RUN:-0}"

# Special case: if user passes 'exports', only clean exports
if [[ "$ARG" == "exports" ]]; then
  ONLY_EXPORTS=1
fi

if [[ -n "$ARG" && "$ONLY_EXPORTS" -eq 0 ]]; then
  if   [[ -d "emoji-forge/$ARG" ]]; then SCOPE="emoji-forge/$ARG"
  elif [[ -d "$ARG"             ]]; then SCOPE="$ARG"
  elif [[ "$ARG" =~ ^[0-9]{3}$  ]]; then SCOPE="emoji-forge/$ARG"; [[ -d "$SCOPE" ]] || { echo "❌ No dir $SCOPE"; exit 1; }
  else
    echo "❌ Invalid target: $ARG"
    echo "   Use: yarn clean                 # all"
    echo "        yarn clean -- 003          # by index"
    echo "        yarn clean -- 003/html     # by folder"
    echo "        yarn clean -- exports      # only exports/"
    exit 1
  fi
fi

echo "🧼 Purrfect Clean starting..."
echo "Scope: ${ONLY_EXPORTS:+exports/ only}${ONLY_EXPORTS:+" "}$([[ "$ONLY_EXPORTS" -eq 0 ]] && echo "$SCOPE")"
[[ "$DRY" == "1" ]] && echo "Mode: DRY RUN (no deletions)"

# 1) Clean exports/
if [[ -d "exports" ]]; then
  if [[ "$DRY" == "1" ]]; then
    echo "— would remove: exports/*"
  else
    rm -rf exports/*
    echo "🗑️  removed: exports/*"
  fi
else
  [[ "$ONLY_EXPORTS" -eq 0 ]] || { echo "ℹ️  exports/ not present"; exit 0; }
fi

# Exit early if only cleaning exports
[[ "$ONLY_EXPORTS" -eq 1 ]] && { echo "✨ Clean done (exports)."; exit 0; }

# 2) Remove generated PNG derivatives inside scope
echo "🔎 scanning for generated artifacts under: $SCOPE"

# neutral files
find "$SCOPE" -type f -name "purr_*_neutral.png" -print0 \
| while IFS= read -r -d '' f; do
  [[ "$DRY" == "1" ]] && { echo "— would remove: $f"; continue; }
  rm -f "$f" && echo "🗑️  removed: $f"
done

# hi-res transparent
find "$SCOPE" -type f -name "purr_*_transparent.png" -print0 \
| while IFS= read -r -d '' f; do
  [[ "$DRY" == "1" ]] && { echo "— would remove: $f"; continue; }
  rm -f "$f" && echo "🗑️  removed: $f"
done

# 128×128 (exclude *_hires.png)
find "$SCOPE" -type f -name "purr_*.png" ! -name "purr_*_hires.png" ! -name "purr_*_transparent.png" -print0 \
| while IFS= read -r -d '' f; do
  [[ "$DRY" == "1" ]] && { echo "— would remove: $f"; continue; }
  rm -f "$f" && echo "🗑️  removed: $f"
done

echo "✨ Clean complete."
