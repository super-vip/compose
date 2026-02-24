ARG GO_VERSION=1.25.7

FROM ghcr.io/loong64/golang:${GO_VERSION}-trixie AS builder

ARG COMPOSE_VERSION=v5.1.0

RUN set -ex; \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    apt-get update; \
    apt-get install -y git file make

RUN set -ex; \
    git clone -b ${COMPOSE_VERSION} https://github.com/docker/compose /opt/compose --depth=1

WORKDIR /opt/compose

ENV CGO_ENABLED=0

RUN set -ex; \
    go mod download -x; \
    make build GO_BUILDTAGS="e2e" DESTDIR=./dist; \
    cd /opt/compose/dist; \
    mv docker-compose docker-compose-linux-$(uname -m)

FROM ghcr.io/loong64/debian:trixie-slim

WORKDIR /opt/compose

COPY --from=builder /opt/compose/dist /opt/compose/dist

VOLUME /dist

CMD cp -rf dist/* /dist/