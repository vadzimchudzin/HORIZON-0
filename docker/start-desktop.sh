#!/bin/bash
set -Eeuo pipefail
export DISPLAY=:1
export HOME=/home/horizon

# Minimal window manager instead of a full XFCE desktop.
openbox-session &
wm_pid=$!
chromium \
  --no-sandbox \
  --user-data-dir=/data/chromium \
  --no-first-run \
  --no-default-browser-check \
  --disable-dev-shm-usage \
  --disable-background-networking \
  --disable-component-update \
  --disable-sync \
  --disable-extensions \
  --disable-breakpad \
  --disable-crash-reporter \
  --disable-features=Translate,MediaRouter \
  --renderer-process-limit=3 \
  --start-maximized \
  about:blank &
chromium_pid=$!
cleanup() {
  kill "${chromium_pid}" "${wm_pid}" 2>/dev/null || true
  wait || true
}
trap cleanup EXIT TERM INT
wait "${chromium_pid}"
