#!/bin/sh

# Fail fast on the first error
set -e

AUTH_ENC=/etc/caddy/auth_users.enc

# Encrypt on first run if the file is plaintext
if ! sops filestatus "$AUTH_ENC" 2>/dev/null | grep -q '"encrypted":true'; then
    if [ -f /config/sops/age/keys.txt ]; then
        AGE_PUB=$(age-keygen -y /config/sops/age/keys.txt)
    elif [ -n "$SOPS_AGE_KEY" ]; then
        AGE_PUB=$(printf '%s' "$SOPS_AGE_KEY" | age-keygen -y)
    else
        echo "ERROR: auth_users is not encrypted and no Age key is available." >&2
        exit 1
    fi
    echo "Encrypting auth_users on first run..."
    sops -e --input-type binary --age "$AGE_PUB" --in-place "$AUTH_ENC"
fi

# Decrypt the file into tmpfs
sops -d "$AUTH_ENC" > /run/secrets/auth_users

# Write upstream proxy config (empty if UPSTREAM_PROXY is not set)
mkdir -p /run/caddy
if [ -n "$UPSTREAM_PROXY" ]; then
    printf 'upstream %s\n' "$UPSTREAM_PROXY" > /run/caddy/upstream_config
else
    : > /run/caddy/upstream_config
fi

# Run Caddy
exec "$@"
