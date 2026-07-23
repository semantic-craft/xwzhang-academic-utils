#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

shopt -s nullglob
tests=("$SCRIPT_DIR"/test_*.sh)
if [[ ${#tests[@]} -eq 0 ]]; then
  echo "No tests found."
  exit 0
fi

for test_file in "${tests[@]}"; do
  bash "$test_file"
done
