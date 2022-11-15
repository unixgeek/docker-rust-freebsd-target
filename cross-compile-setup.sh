#!/bin/sh -ex

RUSTC_TRIPLE="aarch64-unknown-linux-musl"
BUILD_DEPENDENCIES="curl ca-certificates xz-utils"

export DEBIAN_FRONTEND=noninteractive
apt-get update
# shellcheck disable=SC2086
apt-get install -y --no-install-recommends ${BUILD_DEPENDENCIES}

groupadd -r rust
useradd -m -r -g rust rust

curl https://sh.rustup.rs -sSf | su rust -c "sh -s -- --default-toolchain ${RUST_RELEASE} -y"
su rust -c ". /home/rust/.cargo/env; rustup target add ${RUSTC_TRIPLE}"

# Cleanup
# shellcheck disable=SC2086
apt-get purge -y ${BUILD_DEPENDENCIES} python2
apt autoremove --purge -y
rm -fr /var/lib/apt/lists/*
rm -f /tmp/cross-compile-setup.sh
