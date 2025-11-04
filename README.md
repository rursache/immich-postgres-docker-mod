# PostgreSQL with VectorChord & pgvecto.rs - Docker Mod

This mod installs and starts PostgreSQL 15 with VectorChord and pgvecto.rs extensions for vector similarity search, based on Immich's official PostgreSQL image: `ghcr.io/immich-app/postgres:15-vectorchord0.4.3-pgvectors0.2.0`.

## Version History

- **v1.1.0** (Current) - Uses VectorChord 0.4.3 + pgvecto.rs 0.2.0 from Immich's official PostgreSQL 15 image
- **v1.0.0** (Legacy) - Uses old pgvecto-rs extension (deprecated)

## Credits

This project is based on the excellent work by the [ImageGenius team](https://github.com/imagegenius/docker-mods/tree/universal-postgres). Thank you for creating the original universal-postgres docker mod!

## Features

- PostgreSQL 15 with VectorChord 0.4.3 and pgvecto.rs 0.2.0 extensions
- Pre-configured with `pg_stat_statements`, `vchord`, and `vectors.so` shared libraries
- Automatic database initialization on first run
- Automatic migration from old pgvecto-rs (v1.0.0) to new extensions
- Extensions automatically created: `pg_stat_statements` and `vectors`
- Based on Immich's official PostgreSQL image for maximum compatibility

## Usage

### With Immich All-in-One (AIO)

This mod works with **any** [ImageGenius Immich](https://github.com/imagegenius/docker-immich) image variant (e.g., `immich:latest`, `immich:openvino`, `immich:cuda`, etc.).

Example with `immich:openvino`:

```bash
docker run -d \
  --name immich \
  --restart unless-stopped \
  --device /dev/dri:/dev/dri \
  -p 8080:8080 \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/Bucharest \
  -e DB_HOSTNAME=localhost \
  -e DB_USERNAME=postgres \
  -e DB_PASSWORD=postgres \
  -e DB_DATABASE_NAME=postgres \
  -e DB_PORT=5432 \
  -e REDIS_HOSTNAME=localhost \
  -e DOCKER_MODS="imagegenius/mods:universal-redis|ghcr.io/rursache/immich-postgres-docker-mod:v1.1.0" \
  -v ~/.immich/config:/config \
  -v ~/.immich/libraries:/libraries \
  -v PATH_TO_PHOTOS:/photos \
  ghcr.io/imagegenius/immich:openvino
```

**Note**: Replace `PATH_TO_PHOTOS` with your actual photos directory path.

### With Other Containers

In docker arguments, set an environment variable:
```bash
DOCKER_MODS=ghcr.io/rursache/immich-postgres-docker-mod:v1.1.0
```

If adding multiple mods, enter them in an array separated by `|`:
```bash
DOCKER_MODS=ghcr.io/rursache/immich-postgres-docker-mod:v1.1.0|linuxserver/mods:other-mod
```

## Configuration

- **PostgreSQL Version**: PostgreSQL 15 (with VectorChord 0.4.3 and pgvecto.rs 0.2.0)
- **Base Image**: `ghcr.io/immich-app/postgres:15-vectorchord0.4.3-pgvectors0.2.0`
- **Default Credentials**:
  - Username: `postgres`
  - Password: `postgres`
  - Database: `postgres`
- **Port**: `5432` (localhost only - do not expose externally)
- **Shared Libraries**: `pg_stat_statements,vchord,vectors.so`

The default `password`, `database`, and `user` for the PostgreSQL installation are all set to `postgres` and cannot be modified using variables. It is important to note that the PostgreSQL port (`5432`) should not be opened, as this mod is intended to be used locally within the container.

## Extensions

The following PostgreSQL extensions are automatically installed:
- **pg_stat_statements**: Track execution statistics of SQL statements
- **vectors**: Vector similarity search extension (includes both VectorChord and pgvecto.rs)
  - **VectorChord 0.4.3**: High-performance vector similarity search
  - **pgvecto.rs 0.2.0**: PostgreSQL vector extension

## Migration from v1.0.0 to v1.1.0

The mod automatically migrates from the old pgvecto-rs extension to the new VectorChord + pgvecto.rs setup:
1. Detects existing installations
2. Drops old vector indexes (they will be recreated by Immich)
3. Updates `shared_preload_libraries` configuration
4. Creates new extensions

No manual intervention required!

## Migrating from External PostgreSQL to Internal

If you're currently using an external PostgreSQL database and want to migrate to the internal PostgreSQL provided by this mod, follow these steps:

### 1. Backup Your External Database

First, create a backup of your existing Immich database from your external PostgreSQL server:

```bash
pg_dump -U postgres -d immich -h your-external-postgres-host -W -F tar -f immich.tar
```

### 2. Copy Backup to Container

Copy the backup file to your Immich container:

```bash
docker cp immich.tar immich:/config/
```

### 3. Restore Database

Enter the container and restore the database:

```bash
# Enter the container
docker exec -it immich bash

# Restore the database
pg_restore -U postgres -d postgres -h localhost -W --clean --no-owner /config/immich.tar
```

When prompted for a password, enter `postgres`.

### 4. Update Configuration

Update your Immich container environment variables to point to localhost:
```bash
-e DB_HOSTNAME=localhost \
-e DB_USERNAME=postgres \
-e DB_PASSWORD=postgres \
-e DB_DATABASE_NAME=postgres \
-e DB_PORT=5432 \
```

### 5. Restart Container

Restart the container to complete the migration:

```bash
docker restart immich
```

Your data should now be fully migrated to the internal PostgreSQL database, and you can safely decommission your external PostgreSQL server!

## Compatibility

- Works with all ImageGenius Immich variants: `immich:latest`, `immich:openvino`, `immich:cuda`, etc.
- Compatible with Immich's official vector search requirements
- Supports automatic migration from older versions

## License

This project maintains the same license as the original ImageGenius universal-postgres mod.
