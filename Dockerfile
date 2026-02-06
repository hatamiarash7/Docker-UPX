# syntax=docker/dockerfile:1

############################## Build Arguments ##############################

ARG ALPINE_VERSION=3.23
ARG BUSYBOX_VERSION=1.37
ARG UPX_VERSION=latest
ARG APP_VERSION=unknown
ARG DATE_CREATED=unknown

############################## Get UPX ##############################

FROM alpine:${ALPINE_VERSION} AS downloader

ARG UPX_VERSION
ARG TARGETARCH
ARG TARGETVARIANT

RUN apk add --no-cache curl jq

# Map Docker platform to UPX architecture naming
RUN case "${TARGETARCH}${TARGETVARIANT}" in \
    "amd64")    UPX_ARCH="amd64" ;; \
    "arm64")    UPX_ARCH="arm64" ;; \
    "armv7")    UPX_ARCH="arm" ;; \
    "armv6")    UPX_ARCH="arm" ;; \
    "386")      UPX_ARCH="i386" ;; \
    *)          echo "Unsupported architecture: ${TARGETARCH}${TARGETVARIANT}" && exit 1 ;; \
    esac && \
    if [ "${UPX_VERSION}" = "latest" ]; then \
    DOWNLOAD_URL=$(curl -fsSL https://api.github.com/repos/upx/upx/releases/latest | \
    jq -r ".assets[] | select(.name | contains(\"${UPX_ARCH}_linux\")) | .browser_download_url"); \
    else \
    DOWNLOAD_URL="https://github.com/upx/upx/releases/download/v${UPX_VERSION}/upx-${UPX_VERSION}-${UPX_ARCH}_linux.tar.xz"; \
    fi && \
    echo "Downloading UPX from: ${DOWNLOAD_URL}" && \
    curl -fsSL "${DOWNLOAD_URL}" -o /upx.tar.xz

############################## Prepare UPX ##############################

FROM busybox:${BUSYBOX_VERSION} AS final

ARG APP_VERSION
ARG DATE_CREATED

LABEL org.opencontainers.image.title="UPX"
LABEL org.opencontainers.image.description="Lightweight Docker image for UPX - compress executables in multi-stage builds"
LABEL org.opencontainers.image.url="https://github.com/hatamiarash7/docker-upx"
LABEL org.opencontainers.image.source="https://github.com/hatamiarash7/docker-upx"
LABEL org.opencontainers.image.documentation="https://github.com/hatamiarash7/docker-upx#readme"
LABEL org.opencontainers.image.vendor="hatamiarash7"
LABEL org.opencontainers.image.authors="hatamiarash7"
LABEL org.opencontainers.image.version="${APP_VERSION}"
LABEL org.opencontainers.image.created="${DATE_CREATED}"
LABEL org.opencontainers.image.licenses="MIT"

WORKDIR /workspace

COPY --from=downloader /upx.tar.xz /tmp/

RUN tar -xf /tmp/upx.tar.xz -C /tmp && \
    mv /tmp/upx-*/upx /bin/upx && \
    chmod +x /bin/upx && \
    rm -rf /tmp/*

# Verify installation
RUN upx --version

ENTRYPOINT ["/bin/upx"]
CMD ["--help"]