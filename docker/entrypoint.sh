#!/bin/bash
set -Eeuo pipefail
: "${PORT:=8080}"
: "${HORIZON_USER:=horizon}"
if [[ ! "${PORT}" =~ ^[0-9]+$ ]] || (( PORT < 1 || PORT > 65535 )); then echo "PORT must be an integer between 1 and 65535" >&2; exit 1; fi
if [[ -z "${HORIZON_PASSWORD:-}" || ${#HORIZON_PASSWORD} -lt 16 ]]; then echo "HORIZON_PASSWORD is required and must contain at least 16 characters" >&2; exit 1; fi
mkdir -p /run/horizon /data/chromium /tmp/.X11-unix
chown -R horizon:horizon /data
htpasswd -Bbc /run/horizon/htpasswd "${HORIZON_USER}" "${HORIZON_PASSWORD}"
chown root:www-data /run/horizon/htpasswd
chmod 0640 /run/horizon/htpasswd
envsubst '${PORT}' < /etc/nginx/templates/horizon.conf.template > /etc/nginx/conf.d/horizon.conf
nginx -t
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf