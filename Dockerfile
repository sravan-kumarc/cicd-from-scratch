FROM python:3.11-alpine AS builder
RUN pip install --no-cache-dir --upgrade \
    pip==25.3 \
    wheel==0.46.2 \
    setuptools==80.9.0
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt 

COPY . .
#----------------

FROM python:3.11-alpine
RUN apk add --no-cache curl
RUN pip install --no-cache-dir --upgrade \
    pip==25.3 \
    wheel==0.46.2 \
    setuptools==80.9.0
RUN addgroup -S appgroup && adduser -S myuser -G appgroup
WORKDIR /app

COPY --from=builder /app /app

RUN chown -R myuser:appgroup /app
USER myuser

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD curl -f http://localhost:5000/health || exit 1
EXPOSE 5000



CMD ["python", "app.py"]