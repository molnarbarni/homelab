# Homelab — Sanitized Setup Overview

Last reviewed: October 2026

This file is a public, sanitized overview for portfolio readers. It is not a live inventory or a recovery runbook. Verify the private server configuration before using commands or making operational changes.

## Host and access

- Host platform: Dell Vostro laptop
- Operating system: Ubuntu Server 26.04 LTS (x86-64)
- Workloads are managed with Docker Compose.
- Selected host-level tasks are managed with systemd services and timers.
- Remote administration uses Tailscale; management interfaces are not intended to be exposed directly to the public internet.
- Hostnames, usernames, LAN/Tailscale addresses, gateway addresses and device identifiers are intentionally omitted.

## Media stack

The Docker Compose media stack includes:

- Jellyfin — media playback
- Seerr — media requests
- Sonarr — TV library management
- Radarr — movie library management
- Prowlarr — indexer management
- Bazarr — subtitle management
- qBittorrent — download client
- FlareSolverr — compatibility helper for supported web challenges

The stack uses an external media disk. Exact mount details, device identifiers, internal URLs and service-specific settings are intentionally kept out of this public summary. Environment variables, credentials, cookies, API keys and tokens must remain outside version control.

Jellyfin hardware transcoding using Intel Quick Sync was tested in the environment. This statement describes a previous test, not a guarantee of current availability.

## Monitoring and automation

The repository includes configuration and documentation for a monitoring stack built around Prometheus and Grafana, with host/container metrics and service availability checks. Shell scripts and systemd timers support selected host health checks and scheduled tasks.

The public dashboard at [Homelab Operations Center](https://molnarbarni.github.io/homelab/) is a separate static demonstration and uses synthetic values. It is not connected to live host metrics and must not be used to assess current service health.

## Backups and recovery

Backup design and limitations are documented in [Backups and Recovery](BACKUPS.md). A documented schedule or script is not proof that a recent backup succeeded. Check the private host's timer/service logs, archive integrity and checksum, and perform a restore test before relying on a backup.

Application databases, application configuration, environment files and other secrets are not stored in this public repository.

## Related documentation

- [Architecture and Services](ARCHITECTURE.md)
- [Network and Remote Access](NETWORK-AND-ACCESS.md)
- [Monitoring](MONITORING.md)
- [Operations and Troubleshooting](OPERATIONS.md)
- [Security Notes](SECURITY.md)

## Public repository hygiene

Do not commit:

- `.env` files, passwords, API keys, access tokens, session cookies or private keys
- Private application databases or personal media metadata
- Raw monitoring exports that could reveal private infrastructure details
- Internal IP addresses, tailnet addresses, host identifiers or disk UUIDs unless there is a clear public documentation need
