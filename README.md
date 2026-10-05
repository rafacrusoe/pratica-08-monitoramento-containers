# Prática 08 — Monitoramento de contêineres

Implementação de uma stack de monitoramento Docker com Grafana, Prometheus e cAdvisor. O projeto cria cargas controladas de CPU, memória, I/O e rede, coleta as métricas correspondentes e registra três capturas reais do dashboard.

## Componentes

- Grafana: visualização e dashboard provisionado automaticamente;
- Prometheus: coleta e armazenamento das séries temporais;
- cAdvisor: exposição das métricas dos contêineres Docker;
- Grafana Image Renderer: captura automatizada do dashboard;
- quatro contêineres de teste: `teste-cpu`, `teste-memoria`, `teste-io` e `teste-rede`.

## Execução local

Pré-requisitos: Docker Engine, Docker Compose v2, `curl`, `jq` e `file`.

```bash
chmod +x scripts/*.sh
./scripts/run-local.sh
```

O Grafana fica disponível em http://localhost:3000 com usuário `admin` e senha `admin`. O Prometheus fica em http://localhost:9090 e o cAdvisor em http://localhost:8080.

Ao final, a pasta `evidencias/` contém:

- captura da linha de base;
- captura durante as quatro cargas;
- captura do comportamento acumulado após a interrupção das cargas;
- métricas brutas e consolidadas em JSON;
- listagem e estatísticas dos contêineres.

## Automação no GitHub Actions

O workflow `.github/workflows/monitoramento.yml` executa a prática em um runner Ubuntu real, valida a stack, gera as cargas, captura o dashboard e publica o artefato `evidencias-pratica-08`.

## Relação entre carga e métrica

- `teste-cpu`: laço contínuo para elevar o uso do processador;
- `teste-memoria`: aloca e mantém 256 MiB com `stress-ng`;
- `teste-io`: grava e remove repetidamente um arquivo de 64 MiB;
- `teste-rede`: faz requisições contínuas ao endpoint de saúde do Prometheus.

As versões das imagens foram fixadas sempre que possível para preservar a reprodutibilidade da atividade.
