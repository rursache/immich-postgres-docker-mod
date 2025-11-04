# PostgreSQL - Universal Docker Mod

**under development**

This mod installs and starts postgresql, to be installed/updated during container start.

In docker arguments, set an environment variable `DOCKER_MODS=imagegenius/mods:universal-postgres`

If adding multiple mods, enter them in an array separated by `|`, such as `DOCKER_MODS=linuxserver/mods:swag-ffmpeg|linuxserver/mods:swag-mod2`

The version of PostgreSQL that is installed can be specified using the `PG_VERSION` variable. For example, `PG_VERSION=14` would install version 14 of PostgreSQL. 

The default `password`, `database`, and `user` for the PostgreSQL installation are all set to `postgres` and cannot be modified using variables. It is important to note that the PostgreSQL port (`5432`) should not be opened, as this mod is intended to be used locally within the container.