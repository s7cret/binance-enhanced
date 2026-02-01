# Binance Enhanced Skill - Docker Image
FROM python:3.11-slim

# Установка системных зависимостей
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    bash \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Создание пользователя приложения
RUN useradd -m -u 1000 appuser && \
    mkdir -p /app && \
    chown -R appuser:appuser /app

WORKDIR /app

# Копирование зависимостей
COPY requirements.txt .

# Установка Python зависимостей
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Копирование исходного кода
COPY . .

# Создание необходимых директорий
RUN mkdir -p \
    security/data \
    security/logs \
    monitoring/dashboard/static \
    monitoring/dashboard/templates \
    test/mocks \
    telegram-bot/data

# Установка прав
RUN chown -R appuser:appuser /app && \
    chmod +x test/testnet.sh test/test_integration.sh

# Переключение на пользователя приложения
USER appuser

# Переменные окружения по умолчанию
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1
ENV TRADE_MODE=paper
ENV LOG_LEVEL=INFO

# Экспозиция портов
EXPOSE 5000  # Telegram bot webhook
EXPOSE 8080  # Monitoring dashboard

# Точка входа
ENTRYPOINT ["python3", "telegram-bot/bot.py"]

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1