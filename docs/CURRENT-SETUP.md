# Homelab – Current Setup

Last documented state: September 2026

This document describes the current working state of the homelab server and the media stack.

Sensitive credentials are intentionally not stored in this repository.
Do not commit passwords, session cookies, API keys, .env files or other secrets.

---

# 1. Server

## Hardware

- Dell Vostro laptop
- Ubuntu Server 26.04.1 LTS amd64
- Hostname: vostro-server
- User: barni

## Network

LAN IPv4:

    192.168.0.167

Tailscale IPv4:

    100.64.72.18

Tailscale IPv6:

    fd7a:115c:a1e0::d62e:4813

Gateway:

    192.168.0.1

SSH:

    ssh vostro

The server is intended to be reachable remotely through Tailscale.
No router port forwarding is required.

---

# 2. Web applications

## LAN access

Jellyfin:

    http://192.168.0.167:8096

Seerr:

    http://192.168.0.167:5055

Sonarr:

    http://192.168.0.167:8989

Radarr:

    http://192.168.0.167:7878

Prowlarr:

    http://192.168.0.167:9696

qBittorrent:

    http://192.168.0.167:8085

Bazarr:

    http://192.168.0.167:6767

## Tailscale access

Jellyfin:

    http://100.64.72.18:8096

Seerr:

    http://100.64.72.18:5055

Sonarr:

    http://100.64.72.18:8989

Radarr:

    http://100.64.72.18:7878

Prowlarr:

    http://100.64.72.18:9696

qBittorrent:

    http://100.64.72.18:8085

Bazarr:

    http://100.64.72.18:6767

---

# 3. Docker media stack

Project:

    ~/homelab/docker/media-stack

Configuration root:

    ~/media-stack/config

Media/data root:

    /mnt/old-media

Docker network:

    media

Environment variables are stored outside Git in the .env file.

Current main services:

- Jellyfin
- Seerr
- Sonarr
- Radarr
- Prowlarr
- Bazarr
- qBittorrent
- FlareSolverr

The download profile is used for qBittorrent.

---

# 4. Docker internal service addresses

Container-to-container communication uses Docker service names instead of the LAN IP.

Jellyfin:

    http://jellyfin:8096

Seerr:

    http://seerr:5055

Sonarr:

    http://sonarr:8989

Radarr:

    http://radarr:7878

Prowlarr:

    http://prowlarr:9696

qBittorrent:

    http://qbittorrent:8085

FlareSolverr:

    http://flaresolverr:8191

---

# 5. Storage

Main media HDD:

- WD Green 4 TB
- Model: WDC WD40EZRX-00SPEB
- SMART status: PASSED
- Filesystem: NTFS
- UUID: D44466C44466A8C6
- Mount point: /mnt/old-media

Current approximate usage:

- Total: 3.7 TB
- Used: 629 GB
- Free: 3.1 TB

## Media directories

    /mnt/old-media/Filmek
    /mnt/old-media/Sorozatok

## Torrent directories

    /mnt/old-media/torrents/incomplete
    /mnt/old-media/torrents/movies
    /mnt/old-media/torrents/tv

The HDD was previously used internally in a PC.

USB 3 operation with the external enclosure proved unstable.
USB 2 operation is currently stable and usable.

Approximate read speed over the stable USB 2 connection is around 34–42 MB/s.

A hardlink test between the torrent/movie storage and media storage was successful.

---

# 6. HDD mount configuration

The HDD is mounted using its UUID.

Current fstab configuration:

    UUID=D44466C44466A8C6 /mnt/old-media ntfs-3g rw,nofail,x-systemd.automount,uid=1000,gid=1000,umask=022 0 0

---

# 7. Jellyfin

Jellyfin is running in Docker.

Media mounts:

    /mnt/old-media/Filmek:/media/movies:ro
    /mnt/old-media/Sorozatok:/media/tv:ro

The media directories are mounted read-only inside Jellyfin.

Jellyfin is configured and working.

Intel Kaby Lake-U integrated graphics (HD 620) hardware transcoding using QSV was tested successfully.

Real playback transcoding was also confirmed.

---

# 8. Sonarr

Sonarr:

    http://192.168.0.167:8989

Tailscale:

    http://100.64.72.18:8989

Root folder:

    /data/Sorozatok

qBittorrent:

    qbittorrent:8085

TV category:

    tv

Episode renaming is currently disabled.

Existing series were imported into Sonarr.

## Hungarian profile

The current HUN profile is designed around Hungarian releases.

Allowed quality:

- 720p
- 1080p

Disabled:

- SD / 480p
- DVD
- 2160p

Upgrade limit:

- WEB 1080p

## Custom Format: Hungarian

Language:

    Hungarian

Score:

    10000

## Custom Format: Hungarian Release title

Regex:

    (?i)(^|[ ._\-])(?:\d+x)?(?:HUN|HUNGARIAN)(?=$|[ ._\-])

Score:

    10000

The regex is intended to recognize release names containing forms such as HUN, HUNGARIAN and 2xHUN.

The profile uses a minimum Custom Format Score of 10000.

---

# 9. Radarr

Radarr:

    http://192.168.0.167:7878

Tailscale:

    http://100.64.72.18:7878

Root folder:

    /data/Filmek

qBittorrent:

    qbittorrent:8085

Movie category:

    movies

Movie renaming is currently disabled.

Existing movies were imported.

## Hungarian profile

Allowed quality:

- 720p
- 1080p

Disabled:

- SD / 480p
- DVD
- 2160p

Upgrade limit:

- WEB 1080p

Custom Format: Hungarian:

    10000

Custom Format: Hungarian Release title:

    10000

Regex:

    (?i)(^|[ ._\-])(?:\d+x)?(?:HUN|HUNGARIAN)(?=$|[ ._\-])

Minimum Custom Format Score:

    10000

---

# 10. Prowlarr

Prowlarr:

    http://192.168.0.167:9696

Tailscale:

    http://100.64.72.18:9696

Prowlarr is used to manage indexers and synchronize them to Sonarr and Radarr.

Docker application connections use:

Sonarr:

    http://sonarr:8989

Radarr:

    http://radarr:7878

Prowlarr itself:

    http://prowlarr:9696

API keys are stored in the applications and are NOT documented here.

Full Sync is appropriate for the current clean integration.

---

# 11. Indexers / torrent sites

The media stack has been tested with Hungarian torrent/indexer sources.

Sources discussed or used include:

- nCore
- HunTorrent

The nCore account setting "Torrent oldalanként" was initially too low.
Increasing it to 100 fixed missing search results for older seasons of Modern Family.

This setting was important because Sonarr Interactive Search initially did not show some releases that were actually available.

Credentials, cookies and session data must never be committed to Git.

---

# 12. FlareSolverr

FlareSolverr is part of the Docker media stack.

Container:

    flaresolverr

Internal address:

    http://flaresolverr:8191

No host port is published.

The container was tested successfully.

Prowlarr has a FlareSolverr proxy configured for applicable indexers.

FlareSolverr is intended to assist with compatible web access challenges.

---

# 13. qBittorrent

qBittorrent:

    http://192.168.0.167:8085

Tailscale:

    http://100.64.72.18:8085

Docker:

    http://qbittorrent:8085

## Categories

Movies:

    movies

TV:

    tv

## Rate scheduler

Global rate limits:

Download:

    1 KiB/s

Upload:

    900 KiB/s

Alternative rate limits:

Download:

    0 KiB/s

Upload:

    900 KiB/s

Alternative rate schedule:

Weekdays:

    02:00–16:00

This results in:

Monday–Friday 02:00–16:00:

    Download: unlimited
    Upload: 900 KiB/s

Monday–Friday 16:00–02:00:

    Download: 1 KiB/s
    Upload: 900 KiB/s

Saturday and Sunday:

    Download: 1 KiB/s
    Upload: 900 KiB/s

The qBittorrent container timezone is:

    Europe/Budapest

---

# 14. Friends and The Big Bang Theory

Friends (Jóbarátok) and The Big Bang Theory are currently treated as exceptions to the normal automated Sonarr workflow.

Complete multi-season packs are difficult for Sonarr to map reliably.

Decision:

- Friends: manual organization
- The Big Bang Theory: manual organization

Other normal TV series should continue using the automated Sonarr workflow.

---

# 15. Multi-season packs

Stable Sonarr handling of complete multi-season packs is limited.

For normal automation, season-by-season releases are preferred.

If a complete multi-season pack is manually acquired, it may need manual organization/import.

This is particularly relevant to:

- Friends
- The Big Bang Theory

---

# 16. Systemd startup

Media stack startup service:

    /etc/systemd/system/media-stack.service

Repository copy:

    ~/homelab/systemd/media-stack.service

The service waits for required network interfaces/IP addresses, the HDD and Docker before starting the media stack.

The media stack is started using:

    docker compose --profile download up -d

The service was tested successfully after reboot.

---

# 17. Firewall

UFW is active.

Default policy:

- incoming: deny
- outgoing: allow

Required LAN/Tailscale access is allowed.

Docker-published ports can bypass some UFW filtering behaviour and should therefore be considered when changing network exposure.

No router port forwarding is required for the current remote-access setup because Tailscale is used.

---

# 18. Monitoring / health checks

The repository contains system monitoring and health-check scripts/services.

Relevant files:

    bash/healthcheck.sh
    bash/server-status.sh

Systemd:

    systemd/homelab-healthcheck.service
    systemd/homelab-healthcheck.timer
    systemd/homelab-heartbeat.service
    systemd/homelab-heartbeat.sh

---

# 19. Git repository

GitHub repository:

    github.com/molnarbarni/homelab

Local repository:

    ~/homelab

Current branch:

    main

The repository intentionally excludes sensitive files.

Do not commit:

- .env
- passwords
- API keys
- session cookies
- authentication tokens
- private keys
- other credentials

---

# 20. Current repository state

The latest existing commit before this documentation update is:

    a453168 Add FlareSolverr to media stack

Previous important commits include:

    0c908ee Add media stack systemd startup service
    6b5c1b2 Move media stack to HDD and fix boot startup
    e5fe141 Document local project handoff
    2a88248 Expand media server stack and documentation
    edd2261 Add prototype Jellyfin media stack

Two local backup files exist outside Git tracking:

    docker/media-stack/compose.yaml.backup-before-flaresolverr
    docker/media-stack/compose.yaml.backup-before-flaresolverr-2026-09-11-145751

These backups are intentionally not tracked.

---

# 21. Recovery overview

In case the server needs to be rebuilt:

1. Install Ubuntu Server.
2. Configure the server user and hostname.
3. Install Docker.
4. Install and authenticate Tailscale.
5. Clone the homelab repository.
6. Recreate the required .env file locally.
7. Mount the media HDD at /mnt/old-media.
8. Verify the HDD filesystem and UUID.
9. Restore Docker media stack configuration.
10. Restore application configuration if separately backed up.
11. Enable the systemd media-stack service.
12. Start the stack.
13. Verify:
    - Jellyfin
    - Seerr
    - Sonarr
    - Radarr
    - Prowlarr
    - qBittorrent
    - Bazarr
    - FlareSolverr
14. Verify remote access through Tailscale.

The Git repository itself does not contain application databases or secrets.

---

# 22. Useful URLs – quick reference

LAN:

    Jellyfin     http://192.168.0.167:8096
    Seerr        http://192.168.0.167:5055
    Sonarr       http://192.168.0.167:8989
    Radarr       http://192.168.0.167:7878
    Prowlarr     http://192.168.0.167:9696
    qBittorrent  http://192.168.0.167:8085
    Bazarr       http://192.168.0.167:6767

Tailscale:

    Jellyfin     http://100.64.72.18:8096
    Seerr        http://100.64.72.18:5055
    Sonarr       http://100.64.72.18:8989
    Radarr       http://100.64.72.18:7878
    Prowlarr     http://100.64.72.18:9696
    qBittorrent  http://100.64.72.18:8085
    Bazarr       http://100.64.72.18:6767

SSH:

    ssh vostro

