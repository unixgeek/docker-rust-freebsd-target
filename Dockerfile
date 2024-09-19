FROM debian:bookworm-20240904-slim

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates libgcc-11-dev

COPY build-clang.sh /tmp/
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    --mount=type=cache,target=/root/.ccache \
    /tmp/build-clang.sh

ARG ARCH=x86_64

# Arbitrary versions aren't supported, but might still work. I don't fully understand cross-compilation...
# Required by the setup-cross-compile and install-freebsd scripts.
ARG FREEBSD_RELEASE=13.4

COPY install-freebsd.sh /tmp/
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    /tmp/install-freebsd.sh

ARG RUST_RELEASE=1.81.0

COPY setup-cross-compile.sh /tmp/
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    /tmp/setup-cross-compile.sh

USER rust
COPY docker-entrypoint.sh /home/rust/
ENV OPENSSL_DIR=/usr/local/freebsd-${FREEBSD_RELEASE}/usr
WORKDIR /src
ENTRYPOINT ["/home/rust/docker-entrypoint.sh"]
CMD ["help"]
