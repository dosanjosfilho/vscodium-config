#!/bin/bash
# =============================================================================
# switch-profile.sh
# Applies a VSCodium profile: syncs extensions (install + uninstall)
# and copies settings.json.
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

echo ""
echo "🔄 Switching to profile: $PROFILE"
echo ""

# ── Settings ──────────────────────────────────────────────────────────────────

cp "$REPO_DIR/$PROFILE/settings.json" "$CONFIG_DIR/settings.json"
echo "✅ settings.json applied"
echo ""

# ── Build list of wanted extensions (strip comments and blank lines) ──────────

WANTED=$(grep -v '^\s*#' "$REPO_DIR/$PROFILE/extensions.txt" \
  | grep -v '^\s*$' \
  | tr '[:upper:]' '[:lower:]')

# ── Uninstall extensions not in the target profile ───────────────────────────

echo "🗑️  Removing extensions not in profile '$PROFILE'..."
echo ""

INSTALLED=$(codium --list-extensions | tr '[:upper:]' '[:lower:]')

while IFS= read -r ext; do
  if ! echo "$WANTED" | grep -qx "$ext"; then
    echo "   ✗ $ext"
    codium --uninstall-extension "$ext" 2>/dev/null || true
  fi
done <<< "$INSTALLED"

echo ""

# ── Install missing extensions ────────────────────────────────────────────────

echo "📦 Installing extensions for profile '$PROFILE'..."
echo ""

while IFS= read -r ext; do
  [[ -z "$ext" ]] && continue
  if echo "$INSTALLED" | grep -qx "$ext"; then
    echo "   ✓ $ext (already installed)"
  else
    echo "   + $ext"
    codium --install-extension "$ext" 2>/dev/null
  fi
done <<< "$WANTED"

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "🎉 Profile '$PROFILE' is ready!"
echo ""
echo "   Reload VSCodium:"
echo "   Cmd+Shift+P → Developer: Reload Window"
echo ""
