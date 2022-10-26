# Docker-UPX

[![Release][release_badge]][release_link]
[![License][badge_license]][link_license]
[![Image size][badge_size_latest]][link_docker_hub]

It's a lightweight Docker image of [UPX](https://upx.github.io/) to use in multi-stage builds.

## Usage

```bash
docker run --rm -w $PWD -v $PWD:$PWD hatamiarash7/upx --best --lzma -o application-compressed ./application
```

## Dockerfile

You can use this image in your Dockerfile for **multi-stage builds** like this:

```dockerfile
##################################### Build #####################################

FROM golang:1.19-alpine as builder

<build>

##################################### Compression #####################################

FROM hatamiarash7/upx:latest as upx

COPY --from=builder /src /

RUN upx --best --lzma -o /app /app-uncompressed

######################################## Final ########################################

FROM scratch

COPY --from=upx /app /app

CMD ["/app"]
```

---

## Support 💛

[![Donate with Bitcoin](https://en.cryptobadges.io/badge/micro/bc1qmmh6vt366yzjt3grjxjjqynrrxs3frun8gnxrz)](https://en.cryptobadges.io/donate/bc1qmmh6vt366yzjt3grjxjjqynrrxs3frun8gnxrz) [![Donate with Ethereum](https://en.cryptobadges.io/badge/micro/0x0831bD72Ea8904B38Be9D6185Da2f930d6078094)](https://en.cryptobadges.io/donate/0x0831bD72Ea8904B38Be9D6185Da2f930d6078094)

[![ko-fi](https://www.ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/D1D1WGU9)

<div><a href="https://payping.ir/@hatamiarash7"><img src="https://cdn.payping.ir/statics/Payping-logo/Trust/blue.svg" height="128" width="128"></a></div>

## Contributing 🤝

Don't be shy and reach out to us if you want to contribute 😉

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request

## Issues

Each project may have many problems. Contributing to the better development of this project by reporting them. 👍

[release_badge]: https://github.com/hatamiarash7/Docker-UPX/actions/workflows/release.yaml/badge.svg
[release_link]: https://github.com/hatamiarash7/Docker-UPX/actions/workflows/release.yaml
[link_license]: https://github.com/hatamiarash7/Docker-UPX/blob/master/LICENSE
[badge_license]: https://img.shields.io/github/license/hatamiarash7/Docker-UPX.svg?longCache=true
[badge_size_latest]: https://img.shields.io/docker/image-size/hatamiarash7/upx/latest?maxAge=30
[link_docker_hub]: https://hub.docker.com/r/hatamiarash7/upx/
