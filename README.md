# Homelab Infrastructure

A self-hosted home lab built to practise Linux system administration, Docker Compose, networking, monitoring, backup automation, and infrastructure operations.

## Highlights

- Ubuntu Server and systemd service management
- Docker Compose and persistent application data
- Tailscale remote access without router port forwarding
- Prometheus, Grafana, Node Exporter, cAdvisor, and Blackbox Exporter
- Automated backup archives, PostgreSQL dumps, checksum validation, and external copies
- Jellyfin media services and supporting applications
- Shell scripts for health checks and operational tasks

## Architecture

The environment runs on an Ubuntu Server host. Docker Compose manages the media and monitoring stacks. Opportunity Radar is maintained in a separate repository.

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

[Opportunity Radar](https://github.com/molnarbarni/opportunity-radar)

## Security and scope

Secrets, credentials, environment files, database dumps, and backup archives must not be committed. Private network settings are specific to the local installation.

Backup archives and checksums are validated by the scripts, but a complete restore drill has not yet been verified. Grafana screenshots will be added after the overview dashboard is finalised.

This repository documents a real, evolving homelab and is intended as a technical portfolio and operational reference.
