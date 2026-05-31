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
cp docs/docker-compose.yml docs/config.env docs/auth_users docs/.sops.yaml .
```

Fill in `config.env`. Put your age public key (printed by `age-keygen`) into `.sops.yaml`, replacing the placeholder. Edit `auth_users` — one `basic_auth` line per proxy user:

```
basic_auth "username" "password"
```

Then **e**ncrypt `auth_users` **i**n place:

```sh
sops -ei auth_users
```

Start the container:

```sh
docker compose up -d
```
