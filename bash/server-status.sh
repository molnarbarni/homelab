#!/bin/bash

echo "================================"
echo "      VOSTRO SERVER STATUS"
echo "================================"

echo
echo "Hostname:"
hostname

echo
echo "Uptime:"
uptime -p

echo
echo "Load:"
uptime | awk -F'load average:' '{ print $2 }'

echo
echo "Memory:"
free -h | grep Mem

echo
echo "Disk:"
df -h / | tail -1

echo
echo "Local IP:"
hostname -I | awk '{print $1}'

echo
echo "Tailscale IP:"
tailscale ip -4

echo
echo "Services:"
echo -n "SSH:       "
systemctl is-active ssh

echo -n "nginx:     "
systemctl is-active nginx

echo -n "Tailscale: "
systemctl is-active tailscaled

echo
echo "Firewall:"
if sudo -n true 2>/dev/null; then
    sudo -n ufw status | head -1
else
    echo "Status: requires sudo"
fi
echo
echo "==============================="
