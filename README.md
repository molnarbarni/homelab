# Homelab Infrastructure

> A real, evolving self-hosted infrastructure lab focused on Linux administration, container operations, networking, monitoring, backups, and reliability.

<p align="center">
  <a href="https://molnarbarni.github.io/homelab/"><strong>🚀 Open the Public Dashboard Demo</strong></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/molnarbarni/homelab">Browse the Source</a>
</p>

**Note:** The public dashboard is a portfolio demo and uses synthetic sample data. It does not expose live metrics from the home network or server.

## What this project demonstrates

- **Linux operations:** Ubuntu Server, systemd services, SSH, shell-based health checks
- **Containers:** Docker Compose, persistent application data, service-level resource limits
- **Networking:** LAN configuration and Tailscale remote access without router port forwarding
- **Monitoring:** Prometheus, Grafana, Node Exporter, cAdvisor, and Blackbox Exporter
- **Backup operations:** automated archives, PostgreSQL dumps, checksum validation, and external copies
- **Self-hosted services:** Jellyfin media stack and supporting applications
- **Documentation:** setup notes, architecture, operational procedures, troubleshooting, and security scope

## Architecture at a glance

The environment runs on an Ubuntu Server host. Docker Compose manages the media and monitoring stacks, while systemd is used for host-level service management and scheduled operational tasks. The public dashboard is deployed separately through GitHub Pages and contains synthetic demonstration data only.

## Documentation

- [Current setup and hardware](docs/CURRENT-SETUP.md)
- [Architecture and services](docs/ARCHITECTURE.md)
- [Network and remote access](docs/NETWORK-AND-ACCESS.md)
- [Monitoring and alerting](docs/MONITORING.md)
- [Backup strategy](docs/BACKUPS.md)
- [Operations and troubleshooting](docs/OPERATIONS.md)
- [Security notes](docs/SECURITY.md)
- [Linux notes](linux/README.md)
- [Firewall](linux/firewall.md)
- [SSH setup](linux/ssh-setup.md)
- [System basics](linux/system-basics.md)
- [Shell scripts](bash/README.md)
- [Media stack](docker/media-stack/README.md)

## Related project

[Opportunity Radar](https://github.com/molnarbarni/opportunity-radar) — a separate project for exploring company financial data and opportunities.

## Security and scope

Secrets, credentials, environment files, database dumps, and backup archives must not be committed. Private network settings are specific to the local installation.

Backup archives and checksums are validated by the scripts, but a complete restore drill has not yet been verified. This repository documents a real, evolving homelab and is intended as a technical portfolio and operational reference.
