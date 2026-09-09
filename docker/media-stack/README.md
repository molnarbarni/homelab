# Media Server Stack

Self-hosted Docker Compose media server running on my Ubuntu Server homelab.

This project is both a usable home media server and a practical environment for learning Docker, Linux administration, networking, storage and service integration.

## Goals

- Self-host movies and TV shows with Jellyfin
- Request movies and TV shows through Seerr
- Manage movies with Radarr
- Manage TV shows with Sonarr
- Centralize indexer management with Prowlarr
- Automatically manage English subtitles with Bazarr
- Use qBittorrent as the download client
- Prefer 1080p media with reasonable file sizes
- Use Intel Quick Sync for Jellyfin hardware transcoding
- Store media on an external HDD
- Keep application configuration separate from media storage
- Access services remotely through Tailscale
- Avoid exposing services directly to the public internet

## Services

### Jellyfin

Media server and playback frontend.

- Container: `jellyfin`
- Port: `8096`
- Movies: `/media/movies`
- TV Shows: `/media/tv`
- Intel Quick Sync hardware acceleration enabled
- Intel HD Graphics 620 exposed as `/dev/dri/renderD128`

### Seerr

Movie and TV request interface.

Connected to:

- Jellyfin
- Radarr
- Sonarr

### Radarr

Movie library management.

Root folder:

`/data/media/movies`

1080p quality configuration:

- WEB 1080p
- Bluray 1080p
- HDTV 1080p
- No 4K
- No Remux

Preferred order:

1. WEB 1080p
2. Bluray 1080p
3. HDTV 1080p

Upgrade cutoff:

`WEB 1080p`

### Sonarr

TV series library management.

Root folder:

`/data/media/tv`

1080p quality configuration:

- WEB 1080p
- Bluray 1080p
- HDTV 1080p
- No 720p
- No 4K
- No Remux

Preferred order:

1. WEB 1080p
2. Bluray 1080p
3. HDTV 1080p

Upgrade cutoff:

`WEB 1080p`

### Prowlarr

Centralized indexer management.

Connected to:

- Sonarr
- Radarr

No indexers are configured yet.

### Bazarr

Automatic subtitle management.

Current configuration:

- Connected to Sonarr
- Connected to Radarr
- English subtitle profile
- English is the default profile for new movies and series
- OpenSubtitles.com provider configured

The target is English subtitles with English audio.

### qBittorrent

Download client.

Current download structure:

```text
/data/
├── media/
│   ├── movies/
│   └── tv/
└── torrents/
    ├── incomplete/
    ├── movies/
    └── tv/
