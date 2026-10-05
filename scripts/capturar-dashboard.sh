#!/usr/bin/env bash
set -euo pipefail

arquivo="${1:?Informe o caminho do arquivo PNG}"
periodo="${2:-now-15m}"
mkdir -p "$(dirname "$arquivo")"

url="http://localhost:3000/render/d/monitoramento-containers/monitoramento-de-containers"
curl -fsS --retry 8 --retry-delay 5 \
  -u admin:admin \
  "${url}?orgId=1&from=${periodo}&to=now&width=1600&height=1100&tz=UTC" \
  -o "$arquivo"

file "$arquivo" | grep -q 'PNG image data'
echo "Dashboard salvo em ${arquivo}."
