# Security Notes

## Network exposure

The homelab uses Tailscale for private remote access and does not rely on router port forwarding.

Keep administrative interfaces private and expose only the services required for the intended use.

Review Docker port bindings and host firewall rules when adding or changing services.

## Credentials and secrets

- Do not commit `.env` files, passwords, API keys, tokens, or private keys.
- Use environment variables or local configuration files for credentials.
- Ensure secret files are excluded by `.gitignore`.
- Never include credentials in screenshots, logs, documentation, or example commands.
- Treat database dumps and backup archives as private data.

## Public repository

Before publishing changes:

1. Review the staged changes.
2. Check for credentials and other sensitive information.
3. Confirm that local backup files and generated artifacts are excluded.
4. Confirm that nested Git repositories remain separate projects.
5. Check that documentation does not disclose secrets.

Private LAN addresses are installation-specific, but credentials and externally reachable management interfaces require particular care.

## Containers and updates

The homelab uses container images for its application stacks.

Review image versions and release notes before updating. Test configuration changes before applying them to running services, and keep a verified backup before significant upgrades.

Avoid assuming that a successful container start proves an application is secure or correctly configured.

## Backups

Backup archives may contain configuration, application data, and database exports. Store them in private locations and restrict access.

A checksum can help detect accidental changes, but it does not encrypt a backup or protect it from unauthorised access.

See [Backups and Recovery](BACKUPS.md).
