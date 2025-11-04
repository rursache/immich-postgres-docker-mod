# PostgreSQL with pgvecto-rs - Docker Mod

This mod installs and starts PostgreSQL 15 with the pgvecto-rs extension (vector similarity search), based on `tensorchord/pgvecto-rs:pg15-v0.2.0`.

## Features

- PostgreSQL 15 with pgvecto-rs extension for vector similarity search
- Pre-configured with `pg_stat_statements` and `vectors.so` shared libraries
- Automatic database initialization on first run
- Extensions automatically created: `pg_stat_statements` and `vectors`

## Usage

In docker arguments, set an environment variable:
```
DOCKER_MODS=imagegenius/mods:universal-postgres
```

If adding multiple mods, enter them in an array separated by `|`:
```
DOCKER_MODS=linuxserver/mods:swag-ffmpeg|linuxserver/mods:swag-mod2
```

## Configuration

- **PostgreSQL Version**: Fixed at PostgreSQL 15 (with pgvecto-rs v0.2.0)
- **Default Credentials**:
  - Username: `postgres`
  - Password: `postgres`
  - Database: `postgres`
- **Port**: `5432` (localhost only - do not expose externally)
- **Shared Libraries**: `pg_stat_statements,vectors.so`

The default `password`, `database`, and `user` for the PostgreSQL installation are all set to `postgres` and cannot be modified using variables. It is important to note that the PostgreSQL port (`5432`) should not be opened, as this mod is intended to be used locally within the container.

## Extensions

The following PostgreSQL extensions are automatically installed:
- **pg_stat_statements**: Track execution statistics of SQL statements
- **vectors**: pgvecto-rs vector similarity search extension