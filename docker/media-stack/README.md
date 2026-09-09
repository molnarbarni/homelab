# Media Stack

Docker Compose based media server prototype.

## Services

- Jellyfin - Media server
- Seerr - Media request interface
- Sonarr - TV library management
- Radarr - Movie library management
- Prowlarr - Indexer management

The download client is intentionally disabled during the prototype phase.

## Internal service addresses

- Jellyfin: http://jellyfin:8096
- Seerr: http://seerr:5055
- Sonarr: http://sonarr:8989
- Radarr: http://radarr:7878
- Prowlarr: http://prowlarr:9696

## Storage

Current prototype storage:

/home/barni/media-prototype

The final media storage will be moved to an external HDD.

Container paths remain unchanged:

- Jellyfin Movies: /media/movies
- Jellyfin TV: /media/tv
- Radarr Movies: /data/media/movies
- Sonarr TV: /data/media/tv

The host storage location is configured using DATA_ROOT in the local .env file.
