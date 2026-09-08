# SSH Setup

- Remote access via Tailscale
- SSH key authentication configured
- Password authentication kept enabled as fallback
- Client-specific SSH config used for easy login

Example client config:

Host vostro
    HostName vostro-server
    User barni
    IdentityFile ~/.ssh/id_ed25519_vostro
    IdentitiesOnly yes
