# Operations and Troubleshooting

## General checks

Start troubleshooting by checking the state of the host and the relevant application stack.

Useful commands:

- `uptime` — host uptime and load
- `free -h` — memory and swap usage
- `df -h` — filesystem capacity
- `systemctl --failed` — failed systemd units
- `docker ps` — running containers
- `docker stats` — live container resource usage

## Docker Compose

Run Compose commands from the directory containing the relevant Compose file.

Useful commands:

- `docker compose ps` — container status
- `docker compose logs --tail=100` — recent logs
- `docker compose config -q` — validate Compose configuration
- `docker compose restart SERVICE` — restart a specific service

Replace `SERVICE` with the relevant service name. Review the impact before restarting services that other applications depend on.

## Monitoring

If metrics or dashboards are unavailable:

1. Check the monitoring containers.
2. Inspect Prometheus targets.
3. Review exporter logs.
4. Verify service addresses, ports, and network access.
5. Check Grafana's data source configuration.

See [Monitoring](MONITORING.md).

## Network troubleshooting

If a service cannot be reached:

1. Confirm the container is running.
2. Check its published ports and listening address.
3. Test from the local network.
4. Check Tailscale connectivity when accessing remotely.
5. Review firewall rules and application logs.

See [Network and Remote Access](NETWORK-AND-ACCESS.md).

## systemd

Useful commands:

- `systemctl status UNIT` — inspect a unit
- `journalctl -u UNIT -n 100 --no-pager` — view recent unit logs
- `systemctl list-timers` — inspect scheduled tasks
- `systemctl --failed` — list failed units

Replace `UNIT` with the actual unit name.

## Media-stack startup checks

The media stack uses a systemd unit to coordinate startup with host dependencies. Network and storage readiness can affect startup after a reboot.

If the stack does not start automatically:

1. Inspect the unit with `systemctl status`.
2. Read its logs with `journalctl`.
3. Check the current host network configuration and required mounts.
4. Validate the Compose configuration.
5. Confirm the container state before attempting recovery.

Do not assume that an inactive systemd unit means all containers are stopped; inspect the containers separately.

## Backups

Check the backup timer, review recent logs, and verify that archives and checksum files exist in the configured private backup locations.

See [Backups and Recovery](BACKUPS.md).
