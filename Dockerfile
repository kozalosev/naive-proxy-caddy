FROM caddy:builder AS builder

RUN xcaddy build \
    --with github.com/caddyserver/forwardproxy@caddy2=github.com/klzgrad/forwardproxy@naive


FROM caddy:alpine

RUN apk add --no-cache curl age \
    && SOPS_VERSION=$(curl -s https://api.github.com/repos/getsops/sops/releases/latest | grep '"tag_name"' | cut -d'"' -f4) \
    && curl -Lo /usr/local/bin/sops "https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.amd64" \
    && chmod +x /usr/local/bin/sops

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
