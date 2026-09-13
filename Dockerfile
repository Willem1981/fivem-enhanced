FROM alpine:latest AS download

ARG CFX_URL

RUN test -n "$CFX_URL" || \
    (echo "ERROR: CFX_URL build argument is required" && exit 1)

RUN apk add --no-cache \
        ca-certificates \
        curl \
        xz \
    && mkdir -p /srv/cfx \
    && curl -fSL --retry 5 --retry-delay 2 \
        "$CFX_URL" \
        -o /tmp/cfx-server.tar.xz \
    && tar -xJf /tmp/cfx-server.tar.xz \
        -C /srv/cfx \
    && rm /tmp/cfx-server.tar.xz


FROM scratch

COPY --from=download /srv/cfx/ /

WORKDIR /opt/cfx-server

EXPOSE 30120/tcp
EXPOSE 30120/udp
EXPOSE 40120/tcp

ENTRYPOINT [
    "/alpine/lib/ld-musl-x86_64.so.1",
    "--library-path",
    "/alpine/usr/lib/v8/:/alpine/lib/:/alpine/usr/lib/",
    "--",
    "/alpine/opt/cfx-server/cfx-server",
    "+set",
    "citizen_dir",
    "/alpine/opt/cfx-server/citizen/"
]
