#!/usr/bin/env bash
set -euo pipefail

etapa="${1:-coleta}"
destino="evidencias/${etapa}"
mkdir -p "$destino"

consultar() {
  local nome="$1"
  local consulta="$2"
  curl -fsSG "http://localhost:9090/api/v1/query" \
    --data-urlencode "query=${consulta}" \
    | jq . > "${destino}/${nome}.json"
}

consultar cpu 'sum by (name) (rate(container_cpu_usage_seconds_total{name=~".*teste-.*"}[1m])) * 100'
consultar memoria 'container_memory_working_set_bytes{name=~".*teste-.*"} / 1024 / 1024'
consultar io 'sum by (name) (rate(container_fs_writes_bytes_total{name=~".*teste-.*"}[1m]))'
consultar rede 'sum by (name) (rate(container_network_receive_bytes_total{name=~".*teste-.*"}[1m]) + rate(container_network_transmit_bytes_total{name=~".*teste-.*"}[1m]))'

jq -n \
  --arg etapa "$etapa" \
  --slurpfile cpu "${destino}/cpu.json" \
  --slurpfile memoria "${destino}/memoria.json" \
  --slurpfile io "${destino}/io.json" \
  --slurpfile rede "${destino}/rede.json" \
  '{etapa: $etapa, cpu: $cpu[0].data.result, memoria: $memoria[0].data.result, io: $io[0].data.result, rede: $rede[0].data.result}' \
  > "${destino}/resumo.json"

echo "Métricas da etapa '${etapa}' salvas em ${destino}."
