#!/bin/bash

SERVER=$(hostname)
DATE=$(date)

DISK_WARNING=80
MEM_WARNING=80
ERRORS=0

echo "================================"
echo "Health check: $SERVER"
echo "Time: $DATE"
echo "================================"

check_service() {
    SERVICE=$1

    if systemctl is-active --quiet "$SERVICE"; then
        echo "[OK] $SERVICE is running"
    else
        echo "[ERROR] $SERVICE is NOT running"
        ERRORS=$((ERRORS + 1))
    fi
}

check_disk() {
    DISK_USAGE=$(df --output=pcent / | tail -1 | tr -dc '0-9')

    if [ "$DISK_USAGE" -ge "$DISK_WARNING" ]; then
        echo "[WARNING] Disk usage: ${DISK_USAGE}%"
    else
        echo "[OK] Disk usage: ${DISK_USAGE}%"
    fi
}

check_memory() {
    MEM_USAGE=$(free | awk '/Mem:/ {printf("%.0f", $3/$2 * 100)}')

    if [ "$MEM_USAGE" -ge "$MEM_WARNING" ]; then
        echo "[WARNING] Memory usage: ${MEM_USAGE}%"
    else
        echo "[OK] Memory usage: ${MEM_USAGE}%"
    fi
}

echo
echo "--- Services ---"
check_service ssh
check_service nginx
check_service tailscaled

echo
echo "--- Resources ---"
check_disk
check_memory

echo
echo "================================"

if [ "$ERRORS" -gt 0 ]; then
    echo "Health check completed with $ERRORS error(s)."
    exit 1
else
    echo "Health check completed successfully."
    exit 0
fi
