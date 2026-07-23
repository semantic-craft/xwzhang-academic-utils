#!/usr/bin/env bash
#
# westlaw-prime.sh — prime the opencli daemon's Chrome session for Westlaw.
#
# Westlaw shows a "Client ID: Select a previous Client ID" + "Restore previous
# session" modal on every fresh browser session, which hijacks the Results.html
# DOM and causes `opencli westlaw secondary-search/paper-download/...` selectors
# to time out. This script:
#
#   1. Opens https://1.next.westlaw.com/ in the opencli automation window
#   2. Locates a Recent Client ID button by partial label match
#      (default: "DESKTOP", override with WESTLAW_CLIENT_ID env var)
#   3. Clicks it to activate the Client ID
#   4. Closes the Client ID dialog
#
# After running this once per daemon lifetime, all subsequent `opencli westlaw`
# commands reuse the primed session.
#
# Usage:
#   westlaw-prime.sh                       # uses Client ID matching "DESKTOP"
#   WESTLAW_CLIENT_ID=DESKFORCE westlaw-prime.sh
#
# Exit codes:
#   0 — primed successfully
#   1 — could not find a Client ID button matching the requested label
#   2 — browser bridge failed (daemon down? Chrome bridge unavailable?)

set -euo pipefail

CLIENT_ID_LABEL="${WESTLAW_CLIENT_ID:-DESKTOP}"
WESTLAW_LANDING="https://1.next.westlaw.com/"
OPENCLI_HOME="${OPENCLI_HOME:-$HOME/.opencli}"
OPENCLI_PAGE_MODULE="$OPENCLI_HOME/node_modules/@jackwener/opencli/dist/src/browser/page.js"
WESTLAW_LOCK_DIR="${WESTLAW_LOCK_DIR:-${TMPDIR:-/tmp}/opencli-westlaw.lock}"
WESTLAW_LOCK_TIMEOUT="${WESTLAW_LOCK_TIMEOUT:-300}"
WESTLAW_LOCK_STALE_SECONDS="${WESTLAW_LOCK_STALE_SECONDS:-900}"

if ! command -v node >/dev/null 2>&1; then
  echo "[westlaw-prime] ERROR: node is required to prime the Westlaw workspace." >&2
  exit 2
fi

if [[ ! -f "$OPENCLI_PAGE_MODULE" ]]; then
  echo "[westlaw-prime] ERROR: could not find OpenCLI browser module at $OPENCLI_PAGE_MODULE" >&2
  echo "[westlaw-prime] hint: reinstall OpenCLI or set OPENCLI_HOME correctly." >&2
  exit 2
fi

echo "[westlaw-prime] opening Westlaw landing in the site:westlaw workspace..."
CLIENT_ID_LABEL="$CLIENT_ID_LABEL" \
WESTLAW_LANDING="$WESTLAW_LANDING" \
WESTLAW_LOCK_DIR="$WESTLAW_LOCK_DIR" \
WESTLAW_LOCK_TIMEOUT="$WESTLAW_LOCK_TIMEOUT" \
WESTLAW_LOCK_STALE_SECONDS="$WESTLAW_LOCK_STALE_SECONDS" \
OPENCLI_PAGE_MODULE="$OPENCLI_PAGE_MODULE" \
node --input-type=module <<'EOF'
import * as fs from 'node:fs';
import * as path from 'node:path';
import { pathToFileURL } from 'node:url';

const pageModulePath = process.env.OPENCLI_PAGE_MODULE;
const clientIdLabel = String(process.env.CLIENT_ID_LABEL || 'DESKTOP');
const landingUrl = String(process.env.WESTLAW_LANDING || 'https://1.next.westlaw.com/');
const lockDir = String(process.env.WESTLAW_LOCK_DIR || '');
const lockTimeoutSeconds = parseInt(process.env.WESTLAW_LOCK_TIMEOUT || '300', 10);
const staleLockSeconds = parseInt(process.env.WESTLAW_LOCK_STALE_SECONDS || '900', 10);

const { Page } = await import(pathToFileURL(pageModulePath).href);

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function fail(message, exitCode = 2) {
  const error = new Error(message);
  error.exitCode = exitCode;
  throw error;
}

async function acquireLock() {
  const deadline = Date.now() + (Number.isFinite(lockTimeoutSeconds) && lockTimeoutSeconds > 0 ? lockTimeoutSeconds : 300) * 1000;
  const staleMs = (Number.isFinite(staleLockSeconds) && staleLockSeconds > 0 ? staleLockSeconds : 900) * 1000;

  while (Date.now() < deadline) {
    try {
      fs.mkdirSync(lockDir, { recursive: false });
      fs.writeFileSync(path.join(lockDir, 'owner.json'), JSON.stringify({
        pid: process.pid,
        reason: 'westlaw-prime.sh',
        started_at: new Date().toISOString(),
      }, null, 2));
      return;
    } catch (error) {
      if (error?.code !== 'EEXIST') throw error;

      try {
        const stat = fs.statSync(lockDir);
        if ((Date.now() - stat.mtimeMs) >= staleMs) {
          fs.rmSync(lockDir, { recursive: true, force: true });
          continue;
        }
      } catch {
        continue;
      }

      await sleep(500);
    }
  }

  console.error('[westlaw-prime] ERROR: another Westlaw command is already using the shared workspace.');
  console.error('[westlaw-prime] hint: wait for it to finish or raise WESTLAW_LOCK_TIMEOUT (seconds).');
  process.exit(2);
}

function releaseLock() {
  if (!lockDir) return;
  fs.rmSync(lockDir, { recursive: true, force: true });
}

const page = new Page('site:westlaw');
await acquireLock();

try {
  await page.goto(landingUrl);
  await page.wait({ time: 2 });

  const signedOut = await page.evaluate(`
    (() => /sign on|sign in|onepass/i.test((document.body?.innerText || '').replace(/\\s+/g, ' ')))()
  `).catch(() => false);

  if (signedOut) {
    fail(
      'Westlaw appears to require an active signed-in session.\n[westlaw-prime] hint: sign in at https://1.next.westlaw.com/ in Chrome first, then retry.',
      2,
    );
  }

  const clickResult = await page.evaluate(`
    ((label) => {
      const normalize = (value) => String(value || '').replace(/\\s+/g, ' ').trim();
      const click = (element) => {
        if (!element) return false;
        element.dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true, view: window }));
        if (typeof element.click === 'function') element.click();
        return true;
      };

      const buttons = [...document.querySelectorAll('button[id^="co_clientID_recent_"]')];
      const entries = buttons.map((button) => ({
        id: button.id,
        label: button.innerText
          .split('\\n')
          .map(normalize)
          .find(Boolean) || normalize(button.textContent),
      })).filter((entry) => entry.label);

      const wanted = normalize(label).toLowerCase();
      const match = entries.find((entry) => entry.label.toLowerCase().includes(wanted));
      if (!match) {
        return { ok: false, available: entries.map((entry) => entry.label) };
      }

      const button = document.getElementById(match.id);
      const close = document.querySelector('button[id^="co_clientID_close_"]');
      click(button);
      if (close) click(close);

      return {
        ok: true,
        matched: match.label,
        hadClose: !!close,
      };
    })(${JSON.stringify(clientIdLabel)})
  `);

  if (!clickResult?.ok) {
    const available = Array.isArray(clickResult?.available) ? clickResult.available.filter(Boolean) : [];
    const details = available.length
      ? `\n[westlaw-prime] visible Client IDs: ${available.join(' | ')}`
      : '';
    fail(`no Recent Client ID button matched '${clientIdLabel}'.${details}`, 1);
  }

  await page.wait({ time: 1 });

  const sanity = await page.evaluate(`
    ((label) => {
      const normalize = (value) => String(value || '').replace(/\\s+/g, ' ').trim().toLowerCase();
      const bodyText = normalize(document.body?.innerText);
      return {
        hasLabel: bodyText.includes(normalize(label)),
      };
    })(${JSON.stringify(clientIdLabel)})
  `).catch(() => ({ hasLabel: false }));

  if (sanity?.hasLabel) {
    console.log(`[westlaw-prime] OK — session primed with Client ID '${clickResult.matched}'.`);
  } else {
    console.warn(`[westlaw-prime] WARNING: post-click sanity check did not confirm '${clientIdLabel}'.`);
    console.warn('[westlaw-prime]          The click may still have worked — proceed with caution.');
  }
} catch (error) {
  console.error(`[westlaw-prime] ERROR: ${error?.message || error}`);
  process.exitCode = error?.exitCode || 2;
} finally {
  await page.closeWindow().catch(() => {});
  releaseLock();
}
EOF
