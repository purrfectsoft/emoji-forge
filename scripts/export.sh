#!/usr/bin/env bash
# ==============================================
#  Purrfect Emoji Forge - Export Utility (v1.1)
#  Collects all Discord-ready emoji into ./exports
#  Strips "purr_" prefix → e.g. purr_js.png → js.png
#  Safe for paths with spaces; no 'mapfile' needed.
# ==============================================

# Force bash even if invoked via /bin/sh
[ -z "${BASH_VERSION:-}" ] && exec bash "$0" "$@"

set -euo pipefail

EXPORT_DIR="exports"

echo "🐾 Starting export process..."

# Ensure fresh target dir
rm -rf "$EXPORT_DIR"
mkdir -p "$EXPORT_DIR"

# Track if we exported anything
exported=0

# Find all finalized emojis (exclude *_hires and *_transparent), null-delimited
# and loop safely even if filenames have spaces.
find emoji-forge -type f -name 'purr_*.png' \
  ! -name '*_hires.png' ! -name '*_transparent.png' -print0 \
| sort -z \
| while IFS= read -r -d '' f; do
    name="$(basename "$f")"
    short="${name#purr_}"
    echo "📦  Exporting $f → $EXPORT_DIR/$short"
    cp "$f" "$EXPORT_DIR/$short"
    exported=1
  done

# Note: due to subshell in pipe, 'exported' won't reflect in parent.
# So, detect emptiness by checking directory contents.
if [ -z "$(ls -A "$EXPORT_DIR")" ]; then
  echo "⚠️  No exportable emoji found."
  exit 0
fi

echo "✨ Export complete!"
echo "🗂️  Drag everything from '$EXPORT_DIR' into Discord."
