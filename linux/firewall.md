# UFW Firewall

## Default policy

- Incoming: deny
- Outgoing: allow

## Allowed services

### Tailscale
- TCP 22 - SSH
- TCP 80 - nginx

### Home LAN - 192.168.0.0/24
- TCP 22 - SSH
- TCP 80 - nginx

## Useful commands

`sudo ufw status verbose` - Show firewall status and policies

`sudo ufw status numbered` - Show numbered rules

`sudo ufw show added` - Show configured rules
