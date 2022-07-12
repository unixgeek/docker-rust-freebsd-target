#!/bin/sh -ev

eval "$(ssh-agent)"
ssh-add /home/rust/.ssh/github
. /home/rust/set-cross-compile-env.sh
export OPENSSL_DIR=/usr/lib/aarch64-linux-gnu
export OPENSSL_INCLUDE_DIR=/usr/include/openssl
export OPENSSL_LIB_DIR=/usr/lib/aarch64-linux-gnu
cd /mnt/
cargo clean
cargo build --release --target aarch64-unknown-linux-gnu