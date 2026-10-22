#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

BACKUP_DIR="${BACKUP_DIR:-${HOME:?HOME must be set}/backups/homelab}"
STAMP="$(date +%Y-%m-%d_%H-%M-%S)"
WORK_DIR="$(mktemp -d)"
ARCHIVE="${BACKUP_DIR}/homelab-${STAMP}.tar.gz"
DB_DUMP="${WORK_DIR}/opportunity-radar.dump"
STOPPED_CONTAINERS=()

cleanup() {
    local status=$?
    trap - EXIT
    set +e

    for ((i=${#STOPPED_CONTAINERS[@]}-1; i>=0; i--)); do
        container="${STOPPED_CONTAINERS[$i]}"
        echo "Visszaindítás: $container"
        docker start "$container" >/dev/null || {
            echo "HIBA: nem sikerült elindítani: $container" >&2
            status=1
        }
    done

    if (( status != 0 )); then
        rm -f -- "$ARCHIVE" "$ARCHIVE.sha256"
        echo "HIBA: a mentés sikertelen (exit code: $status)." >&2
    fi

    rm -rf -- "$WORK_DIR"
    exit "$status"
}
trap cleanup EXIT

mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

echo "===== HomeLab mentés: ${STAMP} ====="

echo "[1/5] PostgreSQL mentése..."
docker exec opportunity-radar-db \
    sh -c 'pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Fc' \
    > "$DB_DUMP"

test -s "$DB_DUMP"
docker exec -i opportunity-radar-db \
    sh -c 'pg_restore --list' < "$DB_DUMP" >/dev/null

echo "[2/5] Sonarr, Radarr és Prowlarr leállítása a konzisztens mentéshez..."
for container in sonarr radarr prowlarr monitoring-grafana monitoring-prometheus; do
    running="$(docker inspect -f '{{.State.Running}}' "$container")"
    if [[ "$running" == "true" ]]; then
        STOPPED_CONTAINERS+=("$container")
        docker stop --time 30 "$container" >/dev/null
        echo "Leállítva: $container"
    fi
done

echo "[3/5] Konfigurációk és alkalmazásadatok tömörítése..."
mkdir -p "$WORK_DIR/payload"
cp "$DB_DUMP" "$WORK_DIR/payload/opportunity-radar.dump"

echo "A Grafana és Prometheus adatainak archiválása..."
docker run --rm --network none \
    -v monitoring_grafana-data:/source:ro \
    -v "$WORK_DIR/payload":/backup \
    alpine:3.22 tar -czf /backup/grafana-data.tar.gz -C /source .

docker run --rm --network none \
    -v monitoring_prometheus-data:/source:ro \
    -v "$WORK_DIR/payload":/backup \
    alpine:3.22 tar -czf /backup/prometheus-data.tar.gz -C /source .

tar -czf "$ARCHIVE" \
    --exclude='*/.git' \
    --exclude='*/.git/*' \
    --exclude='*/.env' \
    --exclude='*/.env.*' \
    --exclude='*/importer/*.txt' \
    --exclude='*/importer/*.pdf' \
    --exclude='*/importer/test-output.json' \
    --exclude='*/audi-page*.png' \
    --exclude='*/audi.html' \
    --exclude='*/.venv-test' \
    --exclude='*/__pycache__' \
    --exclude='*/.pytest_cache' \
    --exclude='*/node_modules' \
    --exclude='*/postgres/data' \
    --exclude='*/backups' \
    --exclude='*/jellyfin-cache' \
    --exclude='*/jellyfin/log' \
    --exclude='*/jellyfin/data/subtitles' \
    --exclude='*/jellyfin/metadata/People' \
    --exclude='*/jellyfin/metadata/library' \
    --exclude='*/ipc-socket' \
    -C "$HOME" \
    homelab/bash \
    homelab/scripts \
    homelab/docker/nginx \
    homelab/docker/monitoring \
    homelab/docker/media-stack \
    homelab/docker/opportunity-radar \
    media-stack/config \
    -C "$WORK_DIR" payload

echo "[4/5] Archívum ellenőrzése..."
tar -tzf "$ARCHIVE" >/dev/null
gzip -t "$ARCHIVE"

echo "[5/5] Ellenőrzőösszeg létrehozása..."
(
    cd "$BACKUP_DIR"
    sha256sum "$(basename "$ARCHIVE")" > "$(basename "$ARCHIVE").sha256"
    sha256sum -c "$(basename "$ARCHIVE").sha256"
)

chmod 600 "$ARCHIVE" "$ARCHIVE.sha256"

echo "Régi mentések takarítása (legfeljebb 7 példány)..."
mapfile -t OLD_BACKUPS < <(
    find "$BACKUP_DIR" -maxdepth 1 -type f \
        -name 'homelab-*.tar.gz' -printf '%f\n' | sort -r
)

if (( ${#OLD_BACKUPS[@]} > 7 )); then
    for old in "${OLD_BACKUPS[@]:7}"; do
        rm -f -- "$BACKUP_DIR/$old" "$BACKUP_DIR/$old.sha256"
        echo "Törölve: $old"
    done
fi

echo "Mentés sikeres: $ARCHIVE"
ls -lh "$ARCHIVE"
