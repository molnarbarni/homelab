# Homelab Project Handoff

Last updated: 2026-09-09

Purpose: restore enough technical context to continue this homelab project in a future ChatGPT conversation.

Do not store passwords, API keys, tokens, private SSH keys or other secrets in this file.

# 1. Server

Hostname: `vostro-server`

OS: `Ubuntu Server 26.04.1 LTS`

Main user: `barni`

Network:
- LAN IP: `192.168.0.167`
- Tailscale IP: `100.64.72.18`
- Gateway: `192.168.0.1`
- Wi-Fi interface: `wlp2s0`

Remote access:
- SSH
- Tailscale
- SSH key authentication
- Password authentication remains enabled as fallback

Tailscale has been tested successfully from:
- phone over mobile data
- work laptop

Windows SSH alias:

`ssh vostro`

# 2. SSH

A separate ED25519 SSH key exists on the Windows work laptop.

The private key stays on the client and must never be committed.

The public key is installed in:

`~/.ssh/authorized_keys`

Windows SSH config uses:

    Host vostro
        HostName vostro-server
        User barni
        IdentityFile C:\Users\molna\.ssh\id_ed25519_vostro
        IdentitiesOnly yes

# 3. Firewall

UFW is enabled.

Defaults:
- incoming: deny
- outgoing: allow

Allowed:
- SSH through Tailscale
- HTTP through Tailscale
- SSH/HTTP from LAN `192.168.0.0/24`

No router port forwarding is configured.

Media services are exposed on the Tailscale IP only.

# 4. Completed Linux Learning

Already practiced:
- users and groups
- chmod / chown / chgrp
- Linux permissions
- processes
- systemd services
- systemd timers
- networking
- DNS
- SSH
- nginx
- logs / journalctl
- UFW
- Bash scripting
- Git/GitHub
- Docker
- Docker Compose

Custom scripts:
- `bash/server-status.sh`
- `bash/healthcheck.sh`

Custom systemd units:
- `systemd/homelab-heartbeat.service`
- `systemd/homelab-heartbeat.sh`
- `systemd/homelab-healthcheck.service`
- `systemd/homelab-healthcheck.timer`

A local Bash alias exists:

`status`

# 5. GitHub

GitHub username: `molnarbarni`

Repository: `homelab`

Local repo:

`/home/barni/homelab`

Normal workflow:

    cd ~/homelab
    git status
    git diff
    git add ...
    git diff --cached
    git commit -m "message"
    git push

Verified latest state:

`2a88248 Expand media server stack and documentation`

At verification time:
- local `main` = `origin/main`
- working tree clean

Important ignored files:
- `.env`
- `.env.*`
- private key patterns
- tokens/secrets
- `HANDOFF.md`

`HANDOFF.md` must remain local and must NOT be pushed to GitHub.

# 6. Docker

Docker Engine and Docker Compose plugin are installed.

User `barni` belongs to the `docker` group.

Previous Docker learning project:

`/home/barni/homelab/docker/nginx`

Concepts already practiced:
- images
- containers
- bind mounts
- Dockerfile
- Compose
- logs
- exec
- networks
- image tags

# 7. Media Server Project

Compose project:

`/home/barni/homelab/docker/media-stack`

Application configs:

`/home/barni/media-stack/config`

Current prototype data:

`/home/barni/media-prototype`

Prototype layout:

    media-prototype/
    ├── media/
    │   ├── movies/
    │   └── tv/
    └── torrents/
        ├── incomplete/
        ├── movies/
        └── tv/

Docker network:

`media-stack`

Running/configured services:
- Jellyfin
- Seerr
- Sonarr
- Radarr
- Prowlarr
- Bazarr
- qBittorrent

Internal service addresses:
- `jellyfin:8096`
- `seerr:5055`
- `sonarr:8989`
- `radarr:7878`
- `prowlarr:9696`
- `bazarr:6767`
- `qbittorrent:8085`

Tailscale access:
- Jellyfin: `100.64.72.18:8096`
- Seerr: `100.64.72.18:5055`
- Sonarr: `100.64.72.18:8989`
- Radarr: `100.64.72.18:7878`
- Prowlarr: `100.64.72.18:9696`
- Bazarr: `100.64.72.18:6767`
- qBittorrent: `100.64.72.18:8085`

# 8. Jellyfin

Media paths inside container:
- `/media/movies`
- `/media/tv`

Current Jellyfin media mount is read-only.

Remote access works through Tailscale.

No public port forwarding.

# 9. Jellyfin Hardware Acceleration

GPUs:

Intel:
`Intel Kaby Lake-U GT2 / HD Graphics 620`

AMD:
`Radeon HD 8550M / R5 M230`

Intel render device:

`/dev/dri/renderD128`

AMD render device:

`/dev/dri/renderD129`

Render group GID at configuration time:

`991`

Jellyfin Compose includes:

    group_add:
      - "991"

    devices:
      - /dev/dri/renderD128:/dev/dri/renderD128

Jellyfin hardware acceleration:

`Intel Quick Sync (QSV)`

QSV device:

`/dev/dri/renderD128`

Intel `iHD` driver was successfully detected.

`vainfo` returned:

`va_openDriver() returns 0`

Enabled hardware decode:
- H264
- HEVC
- MPEG2
- VC1
- VP8
- VP9
- HEVC 10-bit
- VP9 10-bit

Disabled:
- AV1
- HEVC RExt

Hardware encoding: enabled

Intel Low-Power encoders: disabled

HEVC transcode output: disabled for now

Tone mapping: disabled for now

A synthetic H264 QSV encode test succeeded:
- 1280x720
- 30 fps
- 150 frames
- about 15x realtime speed

A real playback/transcode test is still pending until media is available.

# 10. Radarr

Purpose: movies

Root folder:

`/data/media/movies`

Quality target: 1080p

Allowed:
- WEB 1080p
- Bluray 1080p
- HDTV 1080p

Disabled:
- 720p
- 2160p / 4K
- Remux 1080p

Preferred order:
1. WEB 1080p
2. Bluray 1080p
3. HDTV 1080p

Upgrades: enabled

Upgrade cutoff:

`WEB 1080p`

Language currently:

`Original`

Future idea:
prefer English and possibly Hungarian / dual-audio releases using Custom Formats.

# 11. Sonarr

Purpose: TV series

Root folder:

`/data/media/tv`

Quality target: 1080p

Allowed:
- WEB 1080p
- Bluray 1080p
- HDTV 1080p

Disabled:
- 720p
- 2160p / 4K
- Remux

Preferred order:
1. WEB 1080p
2. Bluray 1080p
3. HDTV 1080p

Upgrades: enabled

Upgrade cutoff:

`WEB 1080p`

# 12. Seerr

Connected to:
- Jellyfin
- Radarr
- Sonarr

Seerr works from the phone through Tailscale.

It is intended to be the main request interface for movies and TV shows.

Current Seerr user is the Owner/admin account.

A manual approval workflow was discussed but intentionally skipped for now.

# 13. Prowlarr

Connected to:
- Sonarr
- Radarr

No indexers are configured yet.

This is intentional.

# 14. Bazarr

Connected to:
- Sonarr
- Radarr

Target:

`English audio + English subtitles`

Language profile:

`English`

English is default for newly added:
- Movies
- Series

Single Language mode: OFF

Provider configured:

`OpenSubtitles.com`

Only one provider is currently configured.

Existing media will need the English Bazarr profile applied after import.

# 15. qBittorrent

qBittorrent is installed and running.

Internal WebUI:

`qbittorrent:8085`

Docker mount:

`${DATA_ROOT}:/data`

Default download path:

`/data/torrents`

Incomplete downloads:

`/data/torrents/incomplete`

Categories:

- `movies` → `/data/torrents/movies`
- `tv` → `/data/torrents/tv`

Sonarr download client:
- Host: `qbittorrent`
- Port: `8085`
- Category: `tv`

Radarr download client:
- Host: `qbittorrent`
- Port: `8085`
- Category: `movies`

Both connection tests succeeded.

No indexers/media sources are configured yet.

# 16. Storage Architecture

Target layout:

    /data/
    ├── torrents/
    │   ├── incomplete/
    │   ├── movies/
    │   └── tv/
    └── media/
        ├── movies/
        └── tv/

qBittorrent, Sonarr, Radarr and Bazarr all see the same `/data` filesystem.

This is intentional for future hardlink support.

Goal:

A downloaded file can remain in:

`/data/torrents/...`

while also appearing in:

`/data/media/...`

without using double disk space.

Jellyfin only sees:
- `/media/movies`
- `/media/tv`

# 17. .env

Local file:

`/home/barni/homelab/docker/media-stack/.env`

It is ignored by Git.

Verified variable names:
- PUID
- PGID
- TZ
- TS_IP
- CONFIG_ROOT
- DATA_ROOT

Current prototype DATA_ROOT:

`/home/barni/media-prototype`

The actual values must never be stored in this HANDOFF file.

# 18. Existing Plex HDD

The external HDD was previously used with Plex on Windows.

It contains approximately 600 GB of existing movies and TV shows.

The media folders were intentionally organized reasonably well.

IMPORTANT:

DO NOT FORMAT THE HDD WHEN IT IS FIRST CONNECTED.

First:
1. identify disk
2. inspect partitions
3. identify filesystem
4. check SMART health
5. mount safely
6. verify existing files

The disk may use NTFS.

Ubuntu can use NTFS.

Do not format it simply because the new server runs Linux.

# 19. Existing Media Migration

Existing Plex media should be reused.

MKV and MP4 files can remain.

Existing subtitle files should also be preserved.

Do NOT bulk rename the entire library immediately.

Recommended process:
1. mount HDD
2. inspect folders
3. verify Jellyfin recognition
4. import movies into Radarr
5. import TV shows into Sonarr
6. test rename on a few files
7. only then consider bulk rename

# 20. Subtitle Plan

Target:

English audio + English subtitles

Bazarr handles subtitles.

OpenSubtitles.com is configured.

Preferred layout:

    Movie (2025)/
    ├── Movie (2025).mkv
    └── Movie (2025).en.srt

# 21. Audio Plan

Bazarr does NOT manage audio tracks.

Future idea:

Use Radarr/Sonarr Custom Formats to prefer:
1. English + Hungarian / dual-audio releases
2. English audio otherwise

Not configured yet.

# 22. Intended Media Workflow

Future normal workflow:

    Phone
    ↓
    Seerr
    ↓
    Radarr / Sonarr
    ↓
    configured source/indexer
    ↓
    qBittorrent
    ↓
    /data/torrents
    ↓
    Radarr / Sonarr import
    ↓
    /data/media
    ↓
    Bazarr subtitles
    ↓
    Jellyfin

Older movies use the same workflow as new movies.

Automatic discovery of highly rated/new content was discussed but is NOT configured yet.

# 23. Security

Never commit:
- `.env`
- passwords
- API keys
- tokens
- private SSH keys

`HANDOFF.md` is intentionally ignored by Git.

Remote access currently uses Tailscale.

No public router port forwarding is required.

# 24. NEXT MAJOR TASK

NEXT STEP: external HDD migration.

Planned sequence:

1. Connect HDD
2. Run `lsblk -f`
3. Identify correct disk
4. Check SMART health
5. Inspect partitions/filesystem
6. DO NOT FORMAT
7. Mount existing filesystem
8. Inspect approximately 600 GB Plex library
9. Choose final permanent mount point
10. Configure permissions
11. Configure persistent mount with UUID and `/etc/fstab` if appropriate
12. Change `DATA_ROOT` in `.env`
13. Recreate media containers
14. Verify Docker mounts
15. Import movies into Radarr
16. Import TV shows into Sonarr
17. Scan libraries in Jellyfin
18. Apply Bazarr English profile to existing media
19. Test Direct Play
20. Force one real 1080p transcode
21. Verify Intel Quick Sync during actual playback

# 25. Later Tasks

After HDD migration:
- configure remaining media automation
- configure appropriate sources/indexers
- consider Seerr request approval workflow
- configure English/Hungarian dual-audio preference
- verify hardlinks
- improve monitoring
- plan backups
- optionally add reverse proxy / HTTPS
- continue DevOps learning path

# Update — 2026-09-10 — Real HDD media stack completed

## Current milestone

The Docker media stack is now using the real 4 TB WD Green HDD instead of the prototype media directory.

The existing media library has been imported successfully into Jellyfin, Radarr and Sonarr.

A full reboot test was completed successfully. The HDD mounts automatically, the network and Tailscale become available, and the complete media stack starts automatically through a dedicated systemd unit.

---

## Storage

Physical HDD:

- Model: WDC WD40EZRX-00SPEB0
- Capacity: 4 TB
- Filesystem: NTFS
- UUID: D44466C44466A8C6
- Mount point: /mnt/old-media
- Current mode: read-write
- SMART status: PASSED
- Reallocated sectors: 0
- Pending sectors: 0
- Offline uncorrectable sectors: 0
- UDMA CRC errors: 0

Important:

Do not depend on /dev/sda, /dev/sdb or /dev/sdc names. The device name changes between boots/reconnects.

Always use the filesystem UUID.

Current /etc/fstab mount:

UUID=D44466C44466A8C6 /mnt/old-media ntfs-3g rw,nofail,x-systemd.automount,uid=1000,gid=1000,umask=022 0 0

A backup of fstab exists:

/etc/fstab.backup

After reboot, findmnt showed the real filesystem mounted read-write through systemd automount.

---

## HDD USB stability

The new AXAGON USB enclosure/bridge showed instability when connected at USB 3 / SuperSpeed.

Observed errors included:

- USB disconnect/reconnect
- uas_zap_pending
- Synchronize Cache failed
- USB bridge re-enumeration

The HDD itself has good SMART values, so the current suspicion is the USB 3 path: cable, connector, port or enclosure bridge.

USB 2 operation has been stable so far.

Read tests completed successfully:

- approximately 2 GB at ~42 MB/s
- 10 GiB continuous read at ~34 MB/s

The 10 GiB read completed without USB disconnect, reset or I/O error.

USB 2 is currently considered usable for the media server.

Do not assume the USB 3 issue is solved.

---

## HDD directory structure

Current host structure:

/mnt/old-media/
├── Filmek/
├── Sorozatok/
├── torrents/
│   ├── incomplete/
│   ├── movies/
│   └── tv/
├── Plex Media Server/
├── $RECYCLE.BIN/
└── System Volume Information/

Existing media is approximately 612 GB.

The existing Filmek and Sorozatok directories were intentionally preserved.

Do not bulk rename, move or reorganize the existing library without testing first.

---

## Docker media storage mapping

The media stack DATA_ROOT was changed from:

/home/barni/media-prototype

to:

/mnt/old-media

The LinuxServer containers see the HDD as:

/data

Therefore:

Radarr:
  /data/Filmek

Sonarr:
  /data/Sorozatok

qBittorrent:
  /data/torrents

qBittorrent incomplete:
  /data/torrents/incomplete

qBittorrent movie category:
  /data/torrents/movies

qBittorrent TV category:
  /data/torrents/tv

Bazarr:
  /data

---

## Jellyfin storage

Jellyfin deliberately uses separate read-only mounts:

Host:
/mnt/old-media/Filmek
→ Container:
/media/movies

Host:
/mnt/old-media/Sorozatok
→ Container:
/media/tv

Both Docker mounts remain read-only even though the host HDD itself is now mounted read-write.

This is intentional.

Jellyfin does not need write access to the original media files.

Jellyfin configuration/cache remain writable under the normal config directories.

---

## Jellyfin library

The full media scan completed successfully.

Both directories are active:

/media/movies
/media/tv

Movies and TV series are now visible in Jellyfin.

Existing movie and TV files were successfully recognized.

Some old MP4/MKV files produce metadata warnings such as:

- UDTA parsing failed
- timescale not set
- unsupported attachment/subtitle codec

These warnings did not stop the library scan.

---

## Jellyfin hardware acceleration

Intel Quick Sync Video is confirmed working.

Hardware device:

/dev/dri/renderD128

Intel iHD driver is working.

A real Pirates of the Caribbean playback test confirmed actual QSV use.

Observed ffmpeg parameters included:

-init_hw_device vaapi=va:/dev/dri/renderD128,driver=iHD
-init_hw_device qsv=qs@va
-hwaccel qsv
-c:v h264_qsv
-codec:v:0 h264_qsv

Therefore the Jellyfin Intel hardware transcoding configuration is verified with a real media file.

Direct Play should still be preferred when the client supports the original media.

---

## Hardlink test

A hardlink test was performed on the NTFS filesystem.

Test source and destination returned the same inode number:

1117

Therefore hardlink creation works on the current ntfs-3g mount.

This is encouraging for the qBittorrent → Radarr/Sonarr workflow.

However, because the underlying filesystem is NTFS under Linux, continue to test real imports before assuming all normal Linux filesystem semantics behave exactly like ext4.

Do not migrate or format the HDD while it contains the only copy of the media.

---

## Radarr

LAN URL:

http://192.168.0.167:7878

Tailscale URL:

http://100.64.72.18:7878

Root folder:

/data/Filmek

Existing movie library imported:

70 movies / 70 unmapped folders were selected during import.

Movies were successfully added to Radarr.

Quality profile was changed to:

HD-1080p

Rename Movies should remain disabled for now until the existing library is fully trusted.

Do not use Search All casually.

Do not bulk rename the existing movie library yet.

qBittorrent connection uses Docker internal networking:

Host: qbittorrent
Port: 8085
Category: movies

The download client Test was successful.

---

## Sonarr

LAN URL:

http://192.168.0.167:8989

Tailscale URL:

http://100.64.72.18:8989

Root folder:

/data/Sorozatok

Existing library imported:

31 series

Quality profile:

HD-1080p

Some automatic matches required manual correction during import.

Important examples:

Daredevil:
corrected to Daredevil (2015)

Hawkeye:
corrected to Hawkeye (2021)

The imported series now appear correctly in Sonarr.

Rename Episodes should remain disabled for now until the existing library is fully trusted.

qBittorrent connection:

Host: qbittorrent
Port: 8085
Category: tv

The download client Test was successful.

---

## qBittorrent

LAN URL:

http://192.168.0.167:8085

Tailscale URL:

http://100.64.72.18:8085

Docker internal host name:

qbittorrent

Internal WebUI port:

8085

Storage:

Default:
  /data/torrents

Incomplete:
  /data/torrents/incomplete

movies category:
  /data/torrents/movies

tv category:
  /data/torrents/tv

Credentials are private and must never be placed in Git or HANDOFF.

No public router port forwarding has been configured.

---

## Bazarr

LAN URL:

http://192.168.0.167:6767

Tailscale URL:

http://100.64.72.18:6767

Bazarr has access to the same /data mount as Radarr and Sonarr.

Radarr and Sonarr integrations were tested successfully.

Current subtitle goal:

English subtitles

Provider previously configured:

OpenSubtitles.com

Bazarr is for subtitles, not audio-track management.

---

## Seerr

LAN URL:

http://192.168.0.167:5055

Tailscale URL:

http://100.64.72.18:5055

Seerr is connected to:

Jellyfin
Radarr
Sonarr

Docker internal service names should be used between containers:

jellyfin:8096
radarr:7878
sonarr:8989

Radarr root:

/data/Filmek

Sonarr root:

/data/Sorozatok

Quality profile:

HD-1080p

Movie minimum availability:

Released

Requests can now be created in Seerr and passed to Radarr/Sonarr.

Important:

Prowlarr currently has no indexers configured.

Therefore Seerr requests can reach Radarr/Sonarr, but the system currently has no configured search source for automatically finding media.

Do not configure copyright-infringing sources.

---

## Prowlarr

LAN URL:

http://192.168.0.167:9696

Tailscale URL:

http://100.64.72.18:9696

Applications:

Sonarr:
  http://sonarr:8989

Radarr:
  http://radarr:7878

Application synchronization is working.

No indexers are currently configured intentionally.

---

## Network access

Server LAN IP:

192.168.0.167

Tailscale IPv4:

100.64.72.18

Media services are bound to both the LAN address and the Tailscale address.

Current ports:

Jellyfin:
  8096

Radarr:
  7878

Sonarr:
  8989

Bazarr:
  6767

Prowlarr:
  9696

Seerr:
  5055

qBittorrent:
  8085

The Docker containers communicate with one another through the Docker media-stack network and service names.

Do not replace internal Docker hostnames with 192.168.0.167 unless there is a specific reason.

---

## Boot-order problem and solution

A real reboot test exposed an important issue.

The Docker containers had:

restart: unless-stopped

but failed during boot because Docker started before the Tailscale address existed.

Example error:

failed to bind host port 100.64.72.18:8096/tcp: cannot assign requested address

The same issue affected:

Jellyfin
Radarr
Sonarr
Bazarr
Prowlarr
Seerr
qBittorrent

A dedicated systemd unit was created:

/etc/systemd/system/media-stack.service

It waits for:

1. Docker
2. network-online.target
3. tailscaled.service
4. LAN address 192.168.0.167
5. Tailscale address 100.64.72.18
6. /mnt/old-media availability

Then runs:

/usr/bin/docker compose --profile download up -d

Working directory:

/home/barni/homelab/docker/media-stack

The unit is enabled at boot.

Successful status after reboot:

media-stack.service
Active: active (exited)

All ExecStartPre checks returned SUCCESS.

All seven media containers were Running after the reboot.

This was verified with an actual full system reboot.

---

## Successful reboot verification

After the final reboot:

qbittorrent:
  Up

bazarr:
  Up

radarr:
  Up

sonarr:
  Up

prowlarr:
  Up

seerr:
  Up

jellyfin:
  Up (healthy)

docker-nginx:
  Up

LAN and Tailscale port bindings were restored automatically.

The media stack can therefore currently recover from a normal server reboot without manual intervention.

---

## Git

Repository:

github.com/molnarbarni/homelab

Local repository:

~/homelab

Verified media storage commit:

6b5c1b2
Move media stack to HDD and fix boot startup

This commit was successfully pushed to origin/main.

The compose file now contains the real HDD mappings and LAN/Tailscale port bindings.

The systemd media-stack.service should also be stored as a repository configuration example under:

systemd/media-stack.service

Verify with git status / git log before assuming the systemd-service copy has been committed, because the final commit output was not captured in the chat.

HANDOFF.md remains intentionally ignored by Git.

Do not commit:

.env
HANDOFF.md
passwords
API keys
SSH private keys
tokens

---

## Current state summary

Working:

- Ubuntu Server
- SSH
- Tailscale
- UFW
- Docker
- Docker Compose
- 4 TB HDD automatic UUID mount
- HDD read/write access
- Jellyfin real media library
- Jellyfin movie library
- Jellyfin TV library
- Intel QSV hardware transcoding
- Radarr real movie library
- Sonarr real TV library
- qBittorrent storage directories
- Bazarr integration
- Seerr integration
- Prowlarr application synchronization
- Docker internal DNS/service networking
- LAN access
- Tailscale remote access
- NTFS hardlink creation
- automatic media-stack startup after reboot

Not completed / future work:

- investigate/fix USB 3 instability
- perform a real end-to-end legal download/import test
- verify hardlinks on a real Radarr/Sonarr import
- test subtitles on newly imported media
- decide whether existing movie/episode rename should ever be enabled
- consider better monitoring/alerting for HDD and containers
- possibly migrate storage to a Linux-native filesystem in the future, but ONLY after safe backup/migration
- add only legitimate/legal content discovery sources if desired
- verify systemd/media-stack.service has been committed to Git
- continue DevOps learning after the media stack milestone

---

## Important safety rules for future work

Do not format the 4 TB HDD.

Do not run mkfs on it.

Do not bulk rename or bulk move the existing Filmek/Sorozatok library without testing.

Do not assume /dev/sdX device names are stable.

Use UUID=D44466C44466A8C6.

Do not expose services through router port forwarding without explicitly designing the security first.

Prefer Tailscale for remote access.

Do not put secrets into Git.

Do not copy SSH private keys between clients.

Do not change multiple storage components simultaneously when troubleshooting.

The media server is currently in a working, reboot-tested state.
