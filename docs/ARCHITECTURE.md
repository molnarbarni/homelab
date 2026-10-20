# Architecture and Services

## Overview

The homelab runs on Ubuntu Server. Docker Compose manages application stacks, while systemd manages selected host-level services and scheduled tasks.

## Media stack

The media stack provides media playback and supporting applications.

Configuration: `docker/media-stack/compose.yaml`

See [Media Stack Documentation](../docker/media-stack/README.md).

## Monitoring stack

The monitoring stack collects host, container, and service availability metrics.

| Component | Purpose |
|---|---|
| Prometheus | Metrics collection and storage |
| Grafana | Dashboards and visualisation |
| Node Exporter | Host-level metrics |
| cAdvisor | Container resource metrics |
| Blackbox Exporter | Network and HTTP availability probes |

Configuration: `docker/monitoring/`

See [Monitoring Documentation](MONITORING.md).

## Separate financial-analysis project

A financial-analysis application is maintained privately with its own repository and deployment lifecycle. Its source code, imported reports, database and runtime configuration are not part of this public homelab repository.

## Database administration reference

A sanitized PostgreSQL + pgAdmin Compose example lives in `docker/postgresql-pgadmin/`. It is a **reference stack**, not proof that this separate database is deployed or connected to an application in the live homelab. The example keeps PostgreSQL off published host ports and binds pgAdmin to loopback by default.

pgAdmin administers PostgreSQL; it is not a Microsoft SQL Server management client. See the [database stack guide](../docker/postgresql-pgadmin/README.md).

## Host automation

Host-level automation includes shell scripts, systemd services, and timers for health checks and backups.

Relevant directories:

- `bash/`
- `scripts/`
- `systemd/`

See [Operations](OPERATIONS.md) and [Backups](BACKUPS.md).

## Design principles

- Keep application stacks independently manageable.
- Keep persistent application data separate from disposable containers.
- Use Tailscale for remote access rather than exposing management interfaces directly to the public internet.
- Exclude credentials and environment files from version control.
- Validate backups and document recovery limitations.
