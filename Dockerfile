#syntax=docker/dockerfile:1.4.3

FROM golang:1.19.4@sha256:f0c32d9dc9a2b9e60d2bd28b51e875be84c6736533720afb67a3e0fecbf31fb7 AS build
# renovate: datasource=github-tags depName=docker/cli
ARG DOCKER_VERSION=20.10.22
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
