#syntax=docker/dockerfile:1.4.2

FROM golang:1.18.5@sha256:fb249eca1b9172732de4950b0fb0fb5c231b83c2c90952c56d822d8a9de4d64b AS build
# renovate: datasource=github-tas depName=docker/cli versioning=regex:^(?<major>1?)\.(?<minor>\\d+?)\.(?<patch>\d+?)
ARG DOCKER_VERSION=20.10.17
WORKDIR /go/src/github.com/docker/cli
RUN git clone -q --config advice.detachedHead=false --depth 1 --branch "v${DOCKER_VERSION}" https://github.com/docker/cli .
ENV GO111MODULE=auto \
    DISABLE_WARN_OUTSIDE_CONTAINER=1
RUN sed -i -E 's|^(\s+)(log.Printf\("WARN:)|\1//\2|' man/generate.go \
 && sed -i -E 's|^(\s+)"log"||' man/generate.go \
 && make manpages
RUN cp -r man/man1 /usr/local/share/man/ \
 && cp -r man/man5 /usr/local/share/man/ \
 && cp -r man/man8 /usr/local/share/man/

FROM scratch
COPY --from=build /usr/local/share /share/
