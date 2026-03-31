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

# ── Extensions managed automatically as dependencies (never uninstall) ────────
# ms-python.python     → ms-python.debugpy, ms-python.vscode-python-envs
# ms-toolsai.jupyter   → jupyter-keymap, jupyter-renderers,
#                        vscode-jupyter-cell-tags, vscode-jupyter-slideshow

MANAGED_DEPS=(
  "ms-python.debugpy"
  "ms-toolsai.jupyter-keymap"
  "ms-toolsai.jupyter-renderers"
  "ms-toolsai.vscode-jupyter-cell-tags"
  "ms-toolsai.vscode-jupyter-slideshow"
)

# ── Uninstall extensions not in the target profile ───────────────────────────

echo "🗑️  Removing extensions not in profile '$PROFILE'..."
echo ""

INSTALLED=$(codium --list-extensions | tr '[:upper:]' '[:lower:]')

while IFS= read -r ext; do
  # Skip if it's a managed dependency
  if printf '%s\n' "${MANAGED_DEPS[@]}" | grep -qx "$ext"; then
    continue
  fi
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
    codium --install-extension "$ext" --ignore-certificate-errors 2>/dev/null
  fi
done <<< "$WANTED"

# ── Always remove ms-python.vscode-python-envs (conflicts with uv) ───────────
# Must run after installs since ms-python.python reinstalls it as a dependency

codium --uninstall-extension ms-python.vscode-python-envs 2>/dev/null || true

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "🎉 Profile '$PROFILE' is ready!"
echo ""
echo "   Reload VSCodium:"
echo "   Cmd+Shift+P → Developer: Reload Window"
echo ""
