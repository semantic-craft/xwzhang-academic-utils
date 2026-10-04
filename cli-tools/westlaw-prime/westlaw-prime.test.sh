#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
cat > "$scratch/scholar" <<'SCRIPT'
#!/usr/bin/env bash
printf '%s\n' "$@" > "$CALLS"
exit 23
SCRIPT
chmod +x "$scratch/scholar"
set +e
OPENCLI_HOME="$scratch/not-installed" CALLS="$scratch/calls" SCHOLAR_BINARY="$scratch/scholar" WESTLAW_CLIENT_ID=DO_NOT_SELECT bash "$ROOT/westlaw-prime.sh" --browser-profile synthetic --session 'caller with spaces' --tab-id page > "$scratch/stdout" 2> "$scratch/stderr"
code=$?
set -e
[[ $code == 23 ]]
cat > "$scratch/expected" <<'EXPECTED'
westlaw
session-prepare
--browser-profile
synthetic
--session
caller with spaces
--tab-id
page
--browser-backend
opencli
EXPECTED
cmp "$scratch/expected" "$scratch/calls"
[[ ! -s "$scratch/stdout" ]]
echo 'PASS: public Scholar argv, no implicit Client ID, exact exit propagation, owned fixture cleanup'
