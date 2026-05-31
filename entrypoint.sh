#!/bin/sh

# Fail fast on the first error
set -e

# Decrypt the files into tmpfs
sops -d /etc/caddy/auth_users.enc > /run/secrets/auth_users

# Run Caddy
exec "$@"
