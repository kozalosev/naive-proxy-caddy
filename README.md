# NaiveProxy Docker Image

Caddy + [klzgrad/naiveproxy](https://github.com/klzgrad/naiveproxy) forwardproxy.
Proxy user list and secrets are kept outside the image and mounted at runtime.
Proxy credentials (`auth_users`) are encrypted at rest with [SOPS](https://github.com/getsops/sops) + Age.

## Prerequisites

Docker and Docker Compose.

Install [age](https://github.com/FiloSottile/age) from your package manager or [GitHub releases](https://github.com/FiloSottile/age/releases). Then generate a key:

```sh
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

## Setup

Copy the example deployment files from `docs/` to your working directory:

```sh
cp docs/docker-compose.yml docs/config.env docs/auth_users .
```

Fill in `config.env`. Edit `auth_users` — one `basic_auth` line per proxy user:

```
basic_auth "username" "password"
```

Start the container:

```sh
docker compose up -d
```

`auth_users` will be encrypted automatically on the first run.

## Upstream proxy chaining (optional)

To route outbound traffic through another proxy (e.g., xray or sing-box), set `UPSTREAM_PROXY` in `config.env`:

```env
# HTTPS / NaiveProxy upstream
UPSTREAM_PROXY=https://user:pass@upstream.example.com:443
# or SOCKS5
UPSTREAM_PROXY=socks5://127.0.0.1:1080
```

If the upstream proxy runs directly on the Docker host, use the host-network compose file:

```sh
cp docs/docker-compose.proxy-on-host.yml ./docker-compose.yml
docker compose up -d
```

This uses `network_mode: host`, giving the container direct access to host-local services via `127.0.0.1`.
