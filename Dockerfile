#syntax=docker/dockerfile:1.4.3

FROM golang:1.19.1@sha256:2d17ffd12a2cdb25d4a633ad25f8dc29608ed84f31b3b983427d825280427095 AS build
# renovate: datasource=github-tags depName=docker/cli
ARG DOCKER_VERSION=20.10.18
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
