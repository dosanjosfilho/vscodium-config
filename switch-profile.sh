#!/bin/bash
# =============================================================================
# switch-profile.sh
# Applies a VSCodium profile: copies settings and installs extensions.
#
# Usage:
#   ./switch-profile.sh data-science
#   ./switch-profile.sh software-engineer
# =============================================================================

set -e

PROFILE="${1}"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/Library/Application Support/VSCodium/User"

# ── Validation ────────────────────────────────────────────────────────────────

if [[ -z "$PROFILE" ]]; then
  echo ""
  echo "Usage: ./switch-profile.sh <profile>"
  echo ""
  echo "Available profiles:"
  for dir in "$REPO_DIR"/*/; do
    echo "  - $(basename "$dir")"
  done
  echo ""
  exit 1
fi

if [[ ! -d "$REPO_DIR/$PROFILE" ]]; then
  echo "❌ Profile '$PROFILE' not found."
  exit 1
fi

# ── Settings ──────────────────────────────────────────────────────────────────

echo ""
echo "🔄 Switching to profile: $PROFILE"
echo ""

cp "$REPO_DIR/$PROFILE/settings.json" "$CONFIG_DIR/settings.json"
echo "✅ settings.json applied"

# ── Extensions ────────────────────────────────────────────────────────────────

echo "📦 Installing extensions..."
echo ""

while IFS= read -r ext; do
  # Skip empty lines and comments
  [[ -z "$ext" || "$ext" == \#* ]] && continue
  echo "   → $ext"
  codium --install-extension "$ext" --force 2>/dev/null
done < "$REPO_DIR/$PROFILE/extensions.txt"

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "🎉 Profile '$PROFILE' is ready!"
echo ""
echo "   Reload VSCodium:"
echo "   Cmd+Shift+P → Developer: Reload Window"
echo ""
