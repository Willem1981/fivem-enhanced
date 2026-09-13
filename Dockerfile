FROM alpine:latest AS builder

ARG CFX_URL
ARG SERVER_DATA_URL=https://github.com/citizenfx/cfx-server-data.git
ARG SERVER_DATA_BRANCH=master

RUN test -n "$CFX_URL" || \
    (echo "ERROR: CFX_URL is required" && exit 1)

RUN test -n "$SERVER_DATA_URL" || \
    (echo "ERROR: SERVER_DATA_URL is required" && exit 1)

RUN apk add --no-cache \
        ca-certificates \
        curl \
        git \
        xz \
    && mkdir -p /opt/cfx-server \
    && curl -fSL --retry 5 --retry-delay 2 \
        "$CFX_URL" \
        -o /tmp/cfx-server.tar.xz \
    && tar -xJf /tmp/cfx-server.tar.xz \
        -C /opt/cfx-server \
    && test -x /opt/cfx-server/FXServer \
    && rm /tmp/cfx-server.tar.xz \
    && git clone \
        --depth 1 \
        --branch "$SERVER_DATA_BRANCH" \
        "$SERVER_DATA_URL" \
        /opt/cfx-server-data


FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        libatomic1 \
        libcurl4 \
        libgcc-s1 \
        libssl3 \
        libstdc++6 \
        xz-utils \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/cfx-server /opt/cfx-server
COPY --from=builder /opt/cfx-server-data /opt/cfx-server-data
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /opt/cfx-server-data

EXPOSE 30120/tcp
EXPOSE 30120/udp
EXPOSE 40120/tcp

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
