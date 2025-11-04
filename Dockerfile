FROM tensorchord/pgvecto-rs:pg15-v0.2.0 AS pgvecto-source

# Build stage to prepare the overlay filesystem
FROM pgvecto-source AS builder

# Copy our local files to a staging directory
COPY root/ /tmp/mod-root/

# Copy PostgreSQL 15 and pgvecto-rs files into the staging directory
RUN mkdir -p /tmp/mod-root/usr/lib/postgresql/15 /tmp/mod-root/usr/share/postgresql/15 && \
    cp -a /usr/lib/postgresql/15/. /tmp/mod-root/usr/lib/postgresql/15/ && \
    cp -a /usr/share/postgresql/15/. /tmp/mod-root/usr/share/postgresql/15/

# Final stage - create the mod overlay
FROM scratch

LABEL maintainer="hydazz"

# Copy the complete overlay filesystem
COPY --from=builder /tmp/mod-root/ /
