#!/usr/bin/env bash
set -Eeuo pipefail

IMAGE="${1:-horizon:ci}"
NAME="horizon-smoke-${RANDOM}"
PORT="${HORIZON_TEST_PORT:-18080}"
PASSWORD="horizon-ci-test-password-2026"

cleanup() {
  docker logs "${NAME}" 2>/dev/null || true
  docker rm -f "${NAME}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker run -d --name "${NAME}" -p "${PORT}:8080" -e PORT=8080 -e HORIZON_USER=horizon -e HORIZON_PASSWORD="${PASSWORD}" --shm-size=512m "${IMAGE}" >/dev/null

ready=0
for attempt in $(seq 1 60); do
  if curl --silent --fail "http://127.0.0.1:${PORT}/healthz" >/dev/null; then ready=1; break; fi
  if [[ "$(docker inspect -f '{{.State.Running}}' "${NAME}")" != "true" ]]; then echo "Container exited before becoming healthy" >&2; exit 1; fi
  sleep 2
done
if [[ "${ready}" != "1" ]]; then echo "Health endpoint did not become ready" >&2; exit 1; fi

unauthorized="$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:${PORT}/vnc.html")"
[[ "${unauthorized}" == "401" ]] || { echo "Expected 401 without credentials, got ${unauthorized}" >&2; exit 1; }

authorized="$(curl -s -o /dev/null -w '%{http_code}' -u "horizon:${PASSWORD}" "http://127.0.0.1:${PORT}/vnc.html")"
[[ "${authorized}" == "200" ]] || { echo "Expected 200 with credentials, got ${authorized}" >&2; exit 1; }

docker exec "${NAME}" chromium --version
docker exec "${NAME}" pgrep -x Xvfb >/dev/null
docker exec "${NAME}" pgrep -x x11vnc >/dev/null
docker exec "${NAME}" pgrep -af 'websockify.*127.0.0.1:6080' >/dev/null
docker exec "${NAME}" pgrep -af 'chromium.*user-data-dir=/data/chromium' >/dev/null

echo "HORIZON smoke tests passed: health, auth boundary, noVNC page, Xvfb, VNC, websockify and Chromium."