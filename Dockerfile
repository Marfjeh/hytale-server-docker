FROM eclipse-temurin:25-jre-alpine

LABEL maintainer="vngdv@andrerm.com"
LABEL description="Hytale Dedicated Server"

RUN addgroup -g 1000 hytale && \
    adduser -D -u 1000 -G hytale hytale

WORKDIR /hytale-server

RUN apk upgrade --no-cache && \
    apk add --no-cache dumb-init curl jq bash unzip && \
    rm -rf /var/cache/apk/*

COPY --chown=hytale:hytale scripts/ /scripts/
COPY --chown=hytale:hytale . /hytale-server

RUN chmod -R 750 /hytale-server && \
    chmod +x /scripts/*.sh

USER hytale

EXPOSE 5520/udp

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/scripts/entrypoint.sh"]

HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD pgrep -f HytaleServer.jar || exit 1