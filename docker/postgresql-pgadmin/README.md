# PostgreSQL + pgAdmin (public reference stack)

This directory is a **sanitized, reusable example** for a small Docker Compose PostgreSQL service with pgAdmin. It is not a copy of any private production database configuration, and publishing it does not mean this exact stack is deployed on the server.

## What runs

- **PostgreSQL 16** stores database data in a named Docker volume.
- **pgAdmin 4** provides the web-based administration UI.
- Both containers share a private Docker bridge network. PostgreSQL has **no host port published**, so it is not directly reachable from the LAN or the public internet.
- pgAdmin is published on `127.0.0.1:5050` by default. The default is intentionally local-only.

> pgAdmin is a PostgreSQL administration tool; it does not manage Microsoft SQL Server. A Microsoft SQL Server deployment needs its own database image/configuration and an appropriate client such as SQL Server Management Studio or Azure Data Studio.

## Start it

From this directory on the host:

```bash
cp .env.example .env
chmod 600 .env
# Generate two distinct secrets (do not use the example placeholders):
openssl rand -base64 36
openssl rand -base64 36
# Edit .env and replace both REPLACE_WITH_* values before continuing.
docker compose config -q
docker compose up -d
docker compose ps
```

Never commit `.env`. The `.env.example` file contains placeholders, not working passwords.

Open `http://127.0.0.1:5050` from the Docker host. To access the UI securely from another machine, create an SSH tunnel from the client:

```bash
ssh -L 5050:127.0.0.1:5050 USERNAME@SERVER
```

Then open `http://127.0.0.1:5050` in the client's browser. Replace `USERNAME` and `SERVER` with the private SSH destination. Do not publish the pgAdmin port directly to the internet.

## Register the PostgreSQL server in pgAdmin

After signing in, register a server with these connection settings:

| Setting | Value |
|---|---|
| Host name/address | `postgres` |
| Port | `5432` |
| Maintenance database | Value of `POSTGRES_DB` in the local `.env` |
| Username | Value of `POSTGRES_USER` in the local `.env` |
| Password | Value of `POSTGRES_PASSWORD` in the local `.env` |

Use `postgres` as the hostname because the two containers communicate over the Compose network. `localhost` inside pgAdmin would refer to the pgAdmin container itself, not the PostgreSQL container.

## Operations

```bash
docker compose ps
docker compose logs --tail=100 postgres
docker compose logs --tail=100 pgadmin
docker compose restart pgadmin
docker compose down
```

`docker compose down` keeps the named volumes. **Do not run `docker compose down -v` unless you explicitly intend to delete the database and pgAdmin configuration volumes.**

Before changing major PostgreSQL or pgAdmin versions, make a verified backup and consult the official upgrade notes. The database data volume is persistent, but a volume is not a backup.

## Adapting it to an existing database

This sample creates a separate database and separate volumes. It does **not** attach pgAdmin to another existing PostgreSQL container automatically. To administer another container, connect both services to a deliberately shared Docker network and register the other container's network DNS name. Keep the database port unpublished unless there is a specific, justified requirement.

## Environment files and public safety

- Keep `.env`, backups, SQL dumps, session data, and credentials out of Git.
- Commit only sanitized Compose files and `.env.example` placeholders.
- The host binding defaults to loopback; do not change it to `0.0.0.0` for convenience.
- This public reference stack is separate from the private Opportunity Radar deployment.

Official references: [PostgreSQL Docker image](https://hub.docker.com/_/postgres) · [pgAdmin container deployment](https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html)
