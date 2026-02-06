############################## Get UPX ##############################

FROM alpine:3.23.3 AS curl

RUN apk add --no-cache curl

RUN curl -sSL $(curl -s https://api.github.com/repos/upx/upx/releases/latest \
    | grep browser_download_url | grep amd64 | cut -d '"' -f 4) -o /upx.tar.xz

############################## Prepare UPX ##############################

FROM busybox:1.37

LABEL org.opencontainers.image.title="UPX"
LABEL org.opencontainers.image.description="Use UPX in Docker multi-stage builds"
LABEL org.opencontainers.image.url="https://github.com/hatamiarash7/docker-upx"
LABEL org.opencontainers.image.source="https://github.com/hatamiarash7/docker-upx"
LABEL org.opencontainers.image.vendor="hatamiarash7"
LABEL org.opencontainers.image.author="hatamiarash7"
LABEL org.opencontainers.version="$APP_VERSION"
LABEL org.opencontainers.image.created="$DATE_CREATED"
LABEL org.opencontainers.image.licenses="MIT"

WORKDIR /

COPY --from=curl /upx.tar.xz /

RUN tar -xf upx.tar.xz \
    && cd upx-*-amd64_linux \
    && mv upx /bin/upx

ENTRYPOINT ["/bin/upx"]