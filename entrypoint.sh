#!/bin/sh

# Fail fast on the first error
set -e

# Decrypt the files into tmpfs
sops -d --output-type dotenv /etc/caddy/secrets.enc.env > /run/secrets/secrets.plain.env
sops -d                      /etc/caddy/auth_users.enc  > /run/secrets/auth_users

# Propagate envs to subprocesses and remove the plain file, we don't need anymore
set -a
source /run/secrets/secrets.plain.env
set +a
rm     /run/secrets/secrets.plain.env

# Run Caddy
exec "$@"
