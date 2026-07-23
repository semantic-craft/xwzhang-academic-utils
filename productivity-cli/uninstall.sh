#!/usr/bin/env bash
# Remove productivity-cli tools from ~/.local/bin.
# Only removes files whose content matches the repo source — never deletes
# a differently-edited tool on the target machine.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_SRC="$SCRIPT_DIR/bin"
LOCAL_BIN="${LOCAL_BIN:-$HOME/.local/bin}"

if [[ ! -d "$BIN_SRC" ]]; then
  echo "Missing source directory: $BIN_SRC" >&2
  exit 1
fi

shopt -s nullglob
removed=0
skipped=0
for tool in "$BIN_SRC"/*; do
  [[ -f "$tool" ]] || continue
  tool_name="$(basename "$tool")"
  dst="$LOCAL_BIN/$tool_name"
  [[ -f "$dst" ]] || { echo "Not installed: $dst"; continue; }

  if cmp -s "$tool" "$dst"; then
    rm -f "$dst"
    echo "Removed: $dst"
    removed=$((removed + 1))
  else
    echo "⚠ Skipped (locally modified): $dst" >&2
    skipped=$((skipped + 1))
  fi
done

echo ""
echo "Removed: $removed | Skipped (local edits): $skipped"
