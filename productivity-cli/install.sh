#!/usr/bin/env bash
# Install productivity-cli tools into ~/.local/bin (or custom LOCAL_BIN).
# Usage:
#   bash install.sh
#   LOCAL_BIN=/custom/bin bash install.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_SRC="$SCRIPT_DIR/bin"
LOCAL_BIN="${LOCAL_BIN:-$HOME/.local/bin}"

if [[ ! -d "$BIN_SRC" ]]; then
  echo "Missing source directory: $BIN_SRC" >&2
  exit 1
fi

mkdir -p "$LOCAL_BIN"

shopt -s nullglob
installed=()
for tool in "$BIN_SRC"/*; do
  [[ -f "$tool" ]] || continue
  tool_name="$(basename "$tool")"
  dst="$LOCAL_BIN/$tool_name"

  tmp="$(mktemp "${dst}.tmp.XXXXXX")"
  cp "$tool" "$tmp"
  chmod 755 "$tmp"
  mv "$tmp" "$dst"
  installed+=("$dst")
  echo "Installed: $dst"
done

if [[ ${#installed[@]} -eq 0 ]]; then
  echo "No tools found in $BIN_SRC"
  echo "The custom Todoist CLI has been retired; use: brew install todoist-cli"
  exit 0
fi

cat <<EOF

✅ Installed ${#installed[@]} tool(s) into $LOCAL_BIN

Make sure $LOCAL_BIN is on your PATH:
  echo \$PATH | tr ':' '\n' | grep -Fx "$LOCAL_BIN" || echo "  ⚠ $LOCAL_BIN is NOT on PATH"
EOF
