# HORIZON

HORIZON — переносимый Docker-контейнер с полноценным Linux desktop и Chromium, доступный через браузер по HTTPS.

## Первый этап
- Debian + XFCE desktop в виртуальном X-дисплее.
- Chromium с постоянным профилем в /data/chromium.
- TigerVNC + noVNC для передачи изображения и событий клавиатуры/мыши.
- Nginx как единственная публичная точка входа.
- HTTP Basic Auth для desktop и WebSocket; VNC и websockify слушают только localhost.
- Docker Compose для локального запуска и GitHub Actions для сборки и smoke-тестов.

## Быстрый запуск
Требуется Docker Engine и Docker Compose.

```bash
cp .env.example .env
# Установите в .env собственный длинный пароль (не используйте пример).
docker compose up --build
```

Откройте http://localhost:8080 и введите HORIZON_USER / HORIZON_PASSWORD из файла .env.
Данные браузера сохраняются в Docker volume horizon-data.

## Переменные окружения
| Переменная | Обязательна | Назначение |
|---|---:|---|
| PORT | нет | HTTP-порт nginx; по умолчанию 8080. Railway передаёт свой PORT автоматически. |
| HORIZON_USER | нет | Имя Basic Auth; по умолчанию horizon. |
| HORIZON_PASSWORD | да | Пароль доступа, минимум 16 символов. Передавать через Secrets/Variables платформы, не коммитить. |

## Railway
1. Создайте новый сервис из этого GitHub-репозитория.
2. Выберите сборку из Dockerfile.
3. Добавьте переменную HORIZON_PASSWORD как secret (не менее 16 символов).
4. При необходимости задайте HORIZON_USER.
5. Добавьте Railway Volume с mount path /data, чтобы профиль Chromium переживал redeploy/restart.
6. Укажите healthcheck path /healthz и включите публичный HTTPS-домен.

Файл railway.json задаёт Dockerfile и healthcheck. Само создание Railway-сервиса и volume не выполняется этим репозиторием.

## Безопасность
- Не публикуйте порты 5900 (VNC) и 6080 (websockify).
- Публичным должен быть только HTTP-порт приложения за HTTPS-прокси Railway.
- Не используйте один пароль для разных сервисов.
- Профиль Chromium содержит cookies и активные сессии. Ограничьте доступ к volume и не добавляйте его содержимое в Git/логи.
- Для реальной эксплуатации предпочтительнее OIDC/SSO или VPN; Basic Auth здесь — минимальная защита MVP.

## Ограничения MVP
Это один интерактивный desktop на один контейнер. Это не multi-user система, не планировщик облачных ресурсов и пока не реализует миграцию между провайдерами. Сначала проверяем desktop end-to-end, затем отдельно проектируем CORE, провайдерные адаптеры и перенос состояния.