FROM tensorchord/pgvecto-rs:pg15-v0.2.0 AS pgvecto-source

# Build stage to prepare the overlay filesystem
FROM pgvecto-source AS builder

# Copy our local files (s6-overlay services) to a staging directory
COPY root/ /tmp/mod-root/

# Copy PostgreSQL 15 and pgvecto-rs files into the staging directory
# This includes:
#   - /usr/lib/postgresql/15/bin/ (postgres, psql, pg_ctl, initdb, etc.)
#   - /usr/lib/postgresql/15/lib/ (shared libraries including vectors.so)
#   - /usr/share/postgresql/15/ (data files, extensions, SQL scripts)
RUN mkdir -p /tmp/mod-root/usr/lib/postgresql/15 \
             /tmp/mod-root/usr/share/postgresql/15 && \
    cp -a /usr/lib/postgresql/15/. /tmp/mod-root/usr/lib/postgresql/15/ && \
    cp -a /usr/share/postgresql/15/. /tmp/mod-root/usr/share/postgresql/15/ && \
    echo "PostgreSQL files copied:" && \
    ls -la /tmp/mod-root/usr/lib/postgresql/15/bin/ | head -5 && \
    ls -la /tmp/mod-root/usr/lib/postgresql/15/lib/ | grep vectors || true

# Final stage - create the mod overlay
FROM scratch

LABEL maintainer="hydazz"

# Copy the complete overlay filesystem
COPY --from=builder /tmp/mod-root/ /
