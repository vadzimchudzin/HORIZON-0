FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive DISPLAY=:1 HOME=/home/horizon PORT=8080
RUN apt-get update && apt-get install -y --no-install-recommends apache2-utils ca-certificates chromium curl dbus-user-session dbus-x11 fonts-liberation fonts-noto-color-emoji gettext-base nginx novnc procps supervisor websockify xfce4 xfce4-terminal x11-utils x11vnc xvfb && rm -rf /var/lib/apt/lists/*
RUN useradd --create-home --shell /bin/bash horizon && mkdir -p /data/chromium /run/horizon /var/log/supervisor && chown -R horizon:horizon /data
COPY docker/entrypoint.sh /usr/local/bin/horizon-entrypoint
COPY docker/start-desktop.sh /usr/local/bin/horizon-start-desktop
COPY docker/nginx.conf.template /etc/nginx/templates/horizon.conf.template
COPY docker/supervisord.conf /etc/supervisor/conf.d/horizon.conf
RUN chmod 0755 /usr/local/bin/horizon-entrypoint /usr/local/bin/horizon-start-desktop && rm -f /etc/nginx/sites-enabled/default
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=45s --retries=3 CMD-SHELL curl -fsS http://127.0.0.1:${PORT:-8080}/healthz || exit 1
ENTRYPOINT ["/usr/local/bin/horizon-entrypoint"]