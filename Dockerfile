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
    && rm /tmp/cfx-server.tar.xz \
    && git clone \
        --depth 1 \
        --branch "$SERVER_DATA_BRANCH" \
        "$SERVER_DATA_URL" \
        /opt/cfx-server-data


FROM scratch

COPY --from=builder / /
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /opt/cfx-server-data

EXPOSE 30120/tcp
EXPOSE 30120/udp
EXPOSE 40120/tcp

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
