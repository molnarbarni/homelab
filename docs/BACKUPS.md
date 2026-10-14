# Backups and Recovery

## Overview

The homelab uses automated backup scripts to create timestamped archives, export PostgreSQL data, validate the resulting files, and copy backups to external storage.

## Backup contents

Depending on the configured backup job, the archive includes selected configuration and operational files from:

- Homelab scripts and documentation
- Docker Compose configurations
- Media-stack configuration
- Monitoring configuration
- Opportunity Radar project files required by the backup process
- PostgreSQL database export
- Selected monitoring application data

Transient files, caches, and other regenerable data may be excluded.

Credentials and environment files should not be published in the public repository. Keep backup archives in private storage.

## Validation

The backup process includes checks intended to detect incomplete or invalid archives.

These include:

- PostgreSQL dump validation using `pg_restore`
- Archive integrity checks
- Compressed archive validation
- SHA-256 checksums
- Checksum verification when copying backups to external storage

The external-copy script uses a temporary destination before renaming the completed copy.

## Retention

The scripts retain a limited number of recent backups. The current configured retention is seven archives in the relevant backup locations.

Confirm the script configuration before changing retention or deleting older backups.

## Scheduling

Backup automation is managed through systemd services and timers.

To inspect the current timer and its next scheduled run, use:

`systemctl list-timers`

To inspect a backup-related unit, use:

`systemctl status NAME.timer`

Replace `NAME.timer` with the actual unit name.

## Recovery considerations

A valid archive is not proof that a full recovery will succeed. A complete restore drill has not yet been verified.

Before relying on the backups for disaster recovery:

1. Identify the required archive and checksum.
2. Verify the checksum.
3. Inspect the archive contents.
4. Restore the database into a test environment.
5. Restore the required configuration and persistent data.
6. Confirm that the applications start and operate correctly.

Do not overwrite production data during a recovery test.

## Related documentation

- [Operations](OPERATIONS.md)
- [Security Notes](SECURITY.md)
