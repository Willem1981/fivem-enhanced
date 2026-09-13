FROM alpine:latest AS server

ARG CFX_URL

RUN test -n "$CFX_URL" || \
    (echo "ERROR: CFX_URL is required" && exit 1)

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
    && rm /tmp/cfx-server.tar.xz


FROM server AS data

RUN git clone \
        --depth 1 \
        https://github.com/citizenfx/cfx-server-data.git \
        /opt/cfx-server-data


FROM scratch

COPY --from=data / /

WORKDIR /opt/cfx-server-data

EXPOSE 30120/tcp
EXPOSE 30120/udp
EXPOSE 40120/tcp

ENTRYPOINT [
    "/alpine/lib/ld-musl-x86_64.so.1",
    "--library-path",
    "/alpine/usr/lib/v8/:/alpine/lib/:/alpine/usr/lib/",
    "--",
    "/opt/cfx-server/cfx-server",
    "+set",
    "citizen_dir",
    "/opt/cfx-server/citizen/"
]

CMD [
    "+exec",
    "server.cfg"
]
