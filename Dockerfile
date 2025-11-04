FROM tensorchord/pgvecto-rs:pg15-v0.2.0 AS pgvecto-source

FROM scratch

LABEL maintainer="hydazz"

# copy local files first to establish directory structure
COPY root/ /

# Copy PostgreSQL 15 and pgvecto-rs binaries from the source image
COPY --from=pgvecto-source /usr/lib/postgresql/15/ /usr/lib/postgresql/15/
COPY --from=pgvecto-source /usr/share/postgresql/15/ /usr/share/postgresql/15/
