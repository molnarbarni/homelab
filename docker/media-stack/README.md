# Media Server Stack

A self-hosted media stack managed with Docker Compose on an Ubuntu Server homelab. This project provides practical experience with Linux administration, containers, networking, storage and service integration.

## Services

| Service | Purpose |
|---|---|
| Jellyfin | Media playback |
| Seerr | Media requests |
| Sonarr | TV library management |
| Radarr | Movie library management |
| Prowlarr | Centralized indexer management |
| Bazarr | Subtitle management |
| qBittorrent | Download client |
| FlareSolverr | Compatibility helper for supported web challenges |

## Design

- Services are managed as a Docker Compose stack.
- Application configuration is kept separate from media files.
- Media is stored on an external disk.
- Tailscale is used for private remote access.
- The setup is intended to avoid exposing management interfaces directly to the public internet.
- Credentials, API keys, cookies, session data and environment files are kept outside Git.

## Media and download paths

The current setup uses separate library folders for movies and TV, plus separate torrent folders for incomplete downloads and completed categories. Exact host paths and mount details are environment-specific; check the private Compose configuration before making changes.

Inside the stack, services should communicate through their Docker service names rather than hard-coded host addresses.

## Hardware transcoding

Jellyfin's Intel Quick Sync hardware transcoding was tested using the host's Intel integrated graphics. Re-check device access and playback transcoding after host, container or driver changes.

## Indexers and application settings

Prowlarr manages indexer integration with Sonarr and Radarr. Indexer accounts, site names, credentials, cookies and detailed private application settings are intentionally not published here.

Quality profiles, root folders, subtitle preferences and download-client settings can change over time. Treat the running application configuration as authoritative and avoid relying on stale values in this README.

## Startup and troubleshooting

The stack is started through Docker Compose, with a systemd unit used for host startup orchestration. For troubleshooting:

1. Check the relevant systemd unit and its journal.
2. Inspect Compose service status and recent logs.
3. Validate the Compose configuration.
4. Check disk mount availability and permissions.
5. Verify Tailscale connectivity separately from LAN access.

See the [homelab operations guide](../../docs/OPERATIONS.md) and [sanitized setup overview](../../docs/CURRENT-SETUP.md).
