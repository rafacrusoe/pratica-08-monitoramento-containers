#!/usr/bin/env bash
set -euo pipefail

mkdir -p evidencias

docker compose up -d grafana prometheus cadvisor renderer

for tentativa in $(seq 1 36); do
  if curl -fsS http://localhost:9090/-/ready >/dev/null \
    && curl -fsS http://localhost:3000/api/health >/dev/null \
    && curl -fsS http://localhost:8080/healthz >/dev/null; then
    break
  fi
  if [ "$tentativa" -eq 36 ]; then
    docker compose ps
    exit 1
  fi
  sleep 5
done

sleep 30
./scripts/coletar-metricas.sh linha-base
./scripts/capturar-dashboard.sh evidencias/01-dashboard-linha-base.png now-5m

docker compose --profile carga up -d load-cpu load-memory load-io load-network
sleep 90
./scripts/coletar-metricas.sh sob-carga
./scripts/capturar-dashboard.sh evidencias/02-dashboard-sob-carga.png now-10m

docker compose stop load-cpu load-memory load-io load-network
sleep 60
./scripts/coletar-metricas.sh apos-carga
./scripts/capturar-dashboard.sh evidencias/03-dashboard-comportamento.png now-15m

docker compose ps -a > evidencias/04-containers.txt
docker stats --no-stream > evidencias/05-docker-stats.txt
echo "Execução concluída. Consulte a pasta evidencias/."
