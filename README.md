# Docker-UPX

[![Release][release_badge]][release_link]
[![License][badge_license]][link_license]
[![Image size][badge_size_latest]][link_docker_hub]
[![Docker Pulls][badge_pulls]][link_docker_hub]
[![GitHub Container Registry][badge_ghcr]][link_ghcr]

A lightweight, multi-architecture Docker image of [UPX](https://upx.github.io/) (Ultimate Packer for eXecutables) designed for compressing binaries in multi-stage Docker builds.

- **Ultra-lightweight** - Based on BusyBox (~4MB total)
- **Multi-architecture support** - `linux/amd64`, `linux/arm64`, `linux/arm/v7`, `linux/arm/v6`, `linux/386`

## Supported Architectures

| Architecture | Tag      |
| ------------ | -------- |
| x86-64       | `amd64`  |
| ARM64        | `arm64`  |
| ARMv7        | `arm/v7` |
| ARMv6        | `arm/v6` |
| x86          | `386`    |

## Quick Start

### Pull the Image

```bash
# From Docker Hub
docker pull hatamiarash7/upx:latest

# From GitHub Container Registry
docker pull ghcr.io/hatamiarash7/upx:latest
```

### Basic Usage

Compress a binary in your current directory:

```bash
docker run --rm -v "$PWD:/workspace" hatamiarash7/upx --best --lzma -o /workspace/app-compressed /workspace/app
```

### Compression Options

| Option          | Description                | Compression Level |
| --------------- | -------------------------- | ----------------- |
| `--best`        | Best compression (slowest) | Maximum           |
| `--lzma`        | Use LZMA algorithm         | Better ratio      |
| `-1` to `-9`    | Compression level          | Variable          |
| `--ultra-brute` | Try even more compression  | Maximum+          |
| `--brute`       | Try more compression       | High              |

## Multi-Stage Build Examples

### Go Application

```dockerfile
# Stage 1: Build
FROM golang:1.23-alpine AS builder

WORKDIR /src
COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app .

# Stage 2: Compress
FROM hatamiarash7/upx:latest AS compressor

COPY --from=builder /app /workspace/app

RUN upx --best --lzma -o /workspace/app-compressed /workspace/app

# Stage 3: Final
FROM scratch

COPY --from=compressor /workspace/app-compressed /app

ENTRYPOINT ["/app"]
```

### Rust Application

```dockerfile
# Stage 1: Build
FROM rust:1.75-alpine AS builder

WORKDIR /src
COPY . .

RUN apk add --no-cache musl-dev && \
    cargo build --release && \
    strip target/release/app

# Stage 2: Compress
FROM hatamiarash7/upx:latest AS compressor

COPY --from=builder /src/target/release/app /workspace/app

RUN upx --best --lzma -o /workspace/app-compressed /workspace/app

# Stage 3: Final
FROM scratch

COPY --from=compressor /workspace/app-compressed /app

ENTRYPOINT ["/app"]
```

### C/C++ Application

```dockerfile
# Stage 1: Build
FROM alpine:3.21 AS builder

RUN apk add --no-cache gcc musl-dev

WORKDIR /src
COPY . .

RUN gcc -static -O3 -o /app main.c && strip /app

# Stage 2: Compress
FROM hatamiarash7/upx:latest AS compressor

COPY --from=builder /app /workspace/app

RUN upx --best --lzma -o /workspace/app-compressed /workspace/app

# Stage 3: Final
FROM scratch

COPY --from=compressor /workspace/app-compressed /app

ENTRYPOINT ["/app"]
```

## Compression Results

Typical compression ratios for statically linked binaries:

| Language | Original | Compressed | Ratio  |
| -------- | -------- | ---------- | ------ |
| Go       | ~10 MB   | ~3-4 MB    | 60-70% |
| Rust     | ~5 MB    | ~1-2 MB    | 60-80% |
| C/C++    | ~1 MB    | ~300 KB    | 70-80% |

> [!NOTE]
> Results vary based on the binary size, content, and compression options used.

## Important Notes

1. **Static binaries only**: UPX works best with statically linked executables
2. **Build flags**: Use `-ldflags="-s -w"` for Go to strip debug info before compression
3. **Startup overhead**: Compressed binaries have slightly longer startup times (~10-50ms)
4. **Memory usage**: Decompression happens in memory at runtime
5. **Anti-virus false positives**: Some AV software may flag UPX-compressed binaries

## Environment Variables

You can customize the build using build arguments:

```bash
docker build \
  --build-arg UPX_VERSION=4.2.4 \
  --build-arg ALPINE_VERSION=3.21 \
  -t my-upx .
```

| Build Arg         | Default  | Description                         |
| ----------------- | -------- | ----------------------------------- |
| `UPX_VERSION`     | `latest` | Specific UPX version to use         |
| `ALPINE_VERSION`  | `3.21`   | Alpine version for downloader stage |
| `BUSYBOX_VERSION` | `1.37`   | BusyBox version for final image     |

---

## 💛 Support

[![Donate with Bitcoin](https://img.shields.io/badge/Bitcoin-bc1qmmh6vt366yzjt3grjxjjqynrrxs3frun8gnxrz-orange)](https://donatebadges.ir/donate/Bitcoin/bc1qmmh6vt366yzjt3grjxjjqynrrxs3frun8gnxrz) [![Donate with Ethereum](https://img.shields.io/badge/Ethereum-0x0831bD72Ea8904B38Be9D6185Da2f930d6078094-blueviolet)](https://donatebadges.ir/donate/Ethereum/0x0831bD72Ea8904B38Be9D6185Da2f930d6078094)

[![ko-fi](https://www.ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/D1D1WGU9)

<div><a href="https://payping.ir/@hatamiarash7"><img src="https://cdn.payping.ir/statics/Payping-logo/Trust/blue.svg" height="128" width="128"></a></div>

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📝 Issues

Found a bug or have a suggestion? [Open an issue](https://github.com/hatamiarash7/Docker-UPX/issues/new) - contributions to improve this project are always welcome! 👍

[release_badge]: https://github.com/hatamiarash7/Docker-UPX/actions/workflows/release.yml/badge.svg
[release_link]: https://github.com/hatamiarash7/Docker-UPX/actions/workflows/release.yml
[link_license]: https://github.com/hatamiarash7/Docker-UPX/blob/master/LICENSE
[badge_license]: https://img.shields.io/github/license/hatamiarash7/Docker-UPX.svg?longCache=true
[badge_size_latest]: https://img.shields.io/docker/image-size/hatamiarash7/upx/latest?maxAge=30
[badge_pulls]: https://img.shields.io/docker/pulls/hatamiarash7/upx
[link_docker_hub]: https://hub.docker.com/r/hatamiarash7/upx/
[badge_ghcr]: https://img.shields.io/badge/ghcr.io-available-blue
[link_ghcr]: https://github.com/hatamiarash7/Docker-UPX/pkgs/container/upx
