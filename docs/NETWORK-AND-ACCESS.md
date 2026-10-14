# Network and Remote Access

## Overview

The homelab is accessed through the local network and Tailscale. Router port forwarding is not part of the intended remote-access setup.

## Local network

Applications may expose ports on the host's LAN address, depending on their Docker Compose configuration.

The host's LAN address and subnet can change when the router or network configuration changes. Check the current host configuration rather than relying on an old address.

## Tailscale

Tailscale provides private remote access to the host and selected services.

Before troubleshooting remote access, verify that:

- Tailscale is running on the server.
- The client device is connected to the expected tailnet.
- The service is configured to listen on an address reachable through Tailscale.
- Host firewall rules permit the required connection.

## Service exposure

Not every service is intended to be reachable from every network interface. Check the relevant Compose configuration to confirm which addresses and ports are published.

Administrative interfaces should remain private. Avoid exposing them directly to the public internet.

## Troubleshooting

If a service is unreachable:

1. Check whether the container is running and healthy.
2. Confirm the service's configured port and listening address.
3. Test access from the local network.
4. Test the Tailscale connection separately.
5. Review the container logs and host firewall rules.
6. Check whether the host's LAN address or subnet has changed.

## Related documentation

- [Current Setup](CURRENT-SETUP.md)
- [Architecture and Services](ARCHITECTURE.md)
- [Security Notes](SECURITY.md)
