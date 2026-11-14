#!/bin/bash
set -Eeuo pipefail
export DISPLAY=:1
export HOME=/home/horizon
startxfce4 &
xfce_pid=$!
chromium --no-sandbox --user-data-dir=/data/chromium --no-first-run --no-default-browser-check --disable-dev-shm-usage --start-maximized about:blank &
chromium_pid=$!
cleanup() { kill "${chromium_pid}" "${xfce_pid}" 2>/dev/null || true; wait || true; }
trap cleanup EXIT TERM INT
wait
