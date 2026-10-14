#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

SRC="/home/barni/backups/homelab"
DST="/mnt/old-media/backups/homelab"
PARTIAL=""

cleanup() {
    local status=$?
    if (( status != 0 )) && [[ -n "$PARTIAL" ]]; then
        rm -f -- "$PARTIAL"
    fi
    exit "$status"
}
trap cleanup EXIT

prune_external_backups() {
    local -a backups=()

    echo "Régi külső mentések takarítása (legfeljebb 7 példány)..."
    mapfile -t backups < <(
        find "$DST" -maxdepth 1 -type f \
            -name 'homelab-*.tar.gz' -printf '%f\\n' | sort -r
    )

    if (( ${#backups[@]} > 7 )); then
        for old in "${backups[@]:7}"; do
            echo "Régi külső mentés törlése: $old"
            rm -f -- "$DST/$old" "$DST/$old.sha256"
        done
    fi
}

if ! mountpoint -q /mnt/old-media; then
    echo "HIBA: a külső lemez nincs csatlakoztatva." >&2
    exit 1
fi

if [[ ! -d "$DST" || ! -w "$DST" ]]; then
    echo "HIBA: a külső mentési könyvtár nem írható." >&2
    exit 1
fi

LATEST="$(find "$SRC" -maxdepth 1 -type f \
    -name 'homelab-*.tar.gz' -printf '%f\n' | sort -r | head -1)"

if [[ -z "$LATEST" || ! -s "$SRC/$LATEST" ]]; then
    echo "HIBA: nem található használható helyi mentés." >&2
    exit 1
fi

echo "Forrás: $LATEST"
SRC_HASH="$(sha256sum "$SRC/$LATEST" | awk '{print $1}')"

if [[ -f "$DST/$LATEST" ]]; then
    DST_HASH="$(sha256sum "$DST/$LATEST" | awk '{print $1}')"
    if [[ "$SRC_HASH" == "$DST_HASH" ]]; then
        echo "A külső példány már naprakész."
        (cd "$DST" && sha256sum "$LATEST" > "$LATEST.sha256")
        (cd "$DST" && sha256sum -c "$LATEST.sha256")
        prune_external_backups
        exit 0
    fi
fi

echo "Mentés másolása a külső lemezre..."
PARTIAL="$DST/$LATEST.partial"
cp "$SRC/$LATEST" "$PARTIAL"

DST_HASH="$(sha256sum "$PARTIAL" | awk '{print $1}')"
if [[ "$SRC_HASH" != "$DST_HASH" ]]; then
    echo "HIBA: a helyi és a másolt fájl hashértéke eltér!" >&2
    exit 1
fi

mv -f -- "$PARTIAL" "$DST/$LATEST"
PARTIAL=""

(cd "$DST" && sha256sum "$LATEST" > "$LATEST.sha256")

echo "A külső példány önálló ellenőrzése:"
(cd "$DST" && sha256sum -c "$LATEST.sha256")

echo "Külső mentés sikeres: $DST/$LATEST"
prune_external_backups
