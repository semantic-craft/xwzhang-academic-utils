#!/usr/bin/env bash
# Compatibility entrypoint: Scholar owns Westlaw context preparation.
# Read-only by default. Client IDs identify customer/matter research attribution,
# not local browser sessions; WESTLAW_CLIENT_ID and DESKTOP are not defaults.
set -euo pipefail
SCHOLAR_BINARY="${SCHOLAR_BINARY:-scholar}"
if ! command -v "$SCHOLAR_BINARY" >/dev/null 2>&1; then
  echo '[westlaw-prime] Scholar is unavailable; select its verified executable with SCHOLAR_BINARY.' >&2
  exit 2
fi
exec "$SCHOLAR_BINARY" westlaw session-prepare "$@" --browser-backend opencli
