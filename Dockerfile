FROM ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0 AS immich-postgres-source

# Build stage to prepare the overlay filesystem
FROM immich-postgres-source AS builder

# Copy our local files (s6-overlay services) to a staging directory
COPY root/ /tmp/mod-root/

# Copy PostgreSQL 14 and VectorChord files into the staging directory
# This includes:
#   - /usr/lib/postgresql/14/bin/ (postgres, psql, pg_ctl, initdb, etc.)
#   - /usr/lib/postgresql/14/lib/ (shared libraries including VectorChord)
#   - /usr/share/postgresql/14/ (data files, extensions, SQL scripts)
#   - System libraries that PostgreSQL depends on
RUN mkdir -p /tmp/mod-root/usr/lib/postgresql/14 \
             /tmp/mod-root/usr/share/postgresql/14 \
             /tmp/mod-root/usr/share/postgresql \
             /tmp/mod-root/usr/share/postgresql-common \
             /tmp/mod-root/usr/lib/x86_64-linux-gnu && \
    cp -a /usr/lib/postgresql/14/. /tmp/mod-root/usr/lib/postgresql/14/ && \
    cp -a /usr/share/postgresql/14/. /tmp/mod-root/usr/share/postgresql/14/ 2>/dev/null || true && \
    cp -a /usr/share/postgresql/. /tmp/mod-root/usr/share/postgresql/ 2>/dev/null || true && \
    cp -a /usr/share/postgresql-common/. /tmp/mod-root/usr/share/postgresql-common/ 2>/dev/null || true && \
    echo "Checking for postgresql.conf.sample..." && \
    find /usr/share -name "postgresql.conf.sample" -exec cp -v {} /tmp/mod-root/usr/share/postgresql/14/ \; || \
    find /tmp/mod-root/usr/share -name "postgresql.conf.sample" || \
    echo "Warning: postgresql.conf.sample not found" && \
    echo "Copying required system libraries..." && \
    # Copy LDAP libraries
    cp -a /usr/lib/x86_64-linux-gnu/libldap* /tmp/mod-root/usr/lib/x86_64-linux-gnu/ 2>/dev/null || true && \
    cp -a /usr/lib/x86_64-linux-gnu/liblber* /tmp/mod-root/usr/lib/x86_64-linux-gnu/ 2>/dev/null || true && \
    # Copy SASL libraries (used by LDAP)
    cp -a /usr/lib/x86_64-linux-gnu/libsasl* /tmp/mod-root/usr/lib/x86_64-linux-gnu/ 2>/dev/null || true && \
    # Copy GSSAPI libraries (used by LDAP)
    cp -a /usr/lib/x86_64-linux-gnu/libgssapi* /tmp/mod-root/usr/lib/x86_64-linux-gnu/ 2>/dev/null || true && \
    # Copy Kerberos libraries
    cp -a /usr/lib/x86_64-linux-gnu/libkrb5* /tmp/mod-root/usr/lib/x86_64-linux-gnu/ 2>/dev/null || true && \
    cp -a /usr/lib/x86_64-linux-gnu/libk5crypto* /tmp/mod-root/usr/lib/x86_64-linux-gnu/ 2>/dev/null || true && \
    cp -a /usr/lib/x86_64-linux-gnu/libcom_err* /tmp/mod-root/usr/lib/x86_64-linux-gnu/ 2>/dev/null || true && \
    # Copy additional PostgreSQL dependencies
    cp -a /usr/lib/x86_64-linux-gnu/libpq* /tmp/mod-root/usr/lib/x86_64-linux-gnu/ 2>/dev/null || true && \
    cp -a /usr/lib/x86_64-linux-gnu/libxml2* /tmp/mod-root/usr/lib/x86_64-linux-gnu/ 2>/dev/null || true && \
    cp -a /usr/lib/x86_64-linux-gnu/libxslt* /tmp/mod-root/usr/lib/x86_64-linux-gnu/ 2>/dev/null || true && \
    cp -a /usr/lib/x86_64-linux-gnu/libicuuc* /tmp/mod-root/usr/lib/x86_64-linux-gnu/ 2>/dev/null || true && \
    cp -a /usr/lib/x86_64-linux-gnu/libicudata* /tmp/mod-root/usr/lib/x86_64-linux-gnu/ 2>/dev/null || true && \
    cp -a /usr/lib/x86_64-linux-gnu/libicui18n* /tmp/mod-root/usr/lib/x86_64-linux-gnu/ 2>/dev/null || true && \
    # Copy UUID libraries
    cp -a /usr/lib/x86_64-linux-gnu/libuuid* /tmp/mod-root/usr/lib/x86_64-linux-gnu/ 2>/dev/null || true && \
    # Copy libkeyutils from /lib or /usr/lib (both locations are tried since /lib may be a symlink)
    cp -a /lib/x86_64-linux-gnu/libkeyutils* /tmp/mod-root/usr/lib/x86_64-linux-gnu/ 2>/dev/null || \
    cp -a /usr/lib/x86_64-linux-gnu/libkeyutils* /tmp/mod-root/usr/lib/x86_64-linux-gnu/ 2>/dev/null || true && \
    echo "System libraries copied"

# Final stage - create the mod overlay
FROM scratch

LABEL maintainer="hydazz"

# Copy the complete overlay filesystem
COPY --from=builder /tmp/mod-root/ /
