# Monitoring

## Overview

The homelab uses Prometheus and Grafana for metrics collection and visualisation. Additional exporters monitor host resources, containers, and service availability.

## Components

| Component | Purpose |
|---|---|
| Prometheus | Collects and stores time-series metrics |
| Grafana | Displays metrics in dashboards |
| Node Exporter | Exposes host-level system metrics |
| cAdvisor | Exposes container resource metrics |
| Blackbox Exporter | Probes network and HTTP endpoints |

## Configuration

The monitoring stack is defined in `docker/monitoring/`.

The current Prometheus configuration uses a 15-second scrape interval and a 30-day data retention period.

Configured checks include host and container metrics, network reachability, and HTTP availability for selected homelab services.

Actual targets and probe settings are defined in the monitoring configuration files.

## Private configuration and access

Copy `docker/monitoring/.env.example` to `docker/monitoring/.env` and set a unique Grafana administrator password before starting the stack. Then edit the target addresses/URLs in your **local** `prometheus/prometheus.yml` copy for the actual router and services. The public version deliberately uses documentation placeholders. Never commit a customized config containing private host addresses or the filled-in `.env`.

The public Compose template binds Grafana and Prometheus to `127.0.0.1` by default. Keep these administration interfaces private. Use an SSH tunnel or deliberately configure a specific private interface locally; do not bind them to `0.0.0.0` or expose them to the public internet.

Validate and start from `docker/monitoring/`:

```bash
cp .env.example .env
chmod 600 .env
# Edit .env before running the stack.
docker compose config -q
docker compose up -d
```

The committed Prometheus target values are placeholders and will not monitor the real local services until you replace them in your local configuration.

## Grafana dashboards

Grafana provides a central view of the homelab's health and resource usage.

Planned documentation improvements:

- Add a screenshot of the overview dashboard.
- Add screenshots of host CPU, memory, disk, and network metrics.
- Add screenshots showing container resources and service availability.

Screenshots will be added under `docs/images/` once the overview dashboard is finalised.

## Troubleshooting

When metrics are missing or stale:

1. Confirm that the monitoring containers are running.
2. Check the Prometheus targets page for scrape errors.
3. Inspect the relevant exporter logs.
4. Verify that the configured target addresses and ports are reachable.
5. Check Grafana's data source configuration if dashboards show no data.

## Related documentation

- [Architecture and Services](ARCHITECTURE.md)
- [Network and Remote Access](NETWORK-AND-ACCESS.md)
- [Operations](OPERATIONS.md)
