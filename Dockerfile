FROM python:3.11-alpine AS builder

WORKDIR /app

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# ─────────────────────────────

FROM python:3.11-alpine

RUN apk add --no-cache curl

RUN addgroup -S appgroup && \
    adduser -S myuser -G appgroup

WORKDIR /app

COPY --from=builder /opt/venv /opt/venv
COPY --from=builder /app /app

ENV PATH="/opt/venv/bin:$PATH"

RUN chown -R myuser:appgroup /app

USER myuser

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=5s \
  --start-period=5s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

CMD ["python", "app.py"]