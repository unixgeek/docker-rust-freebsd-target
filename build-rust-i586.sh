#!/bin/bash -e

if [ $# -ne 1 ]; then
  echo "usage: $(basename "${0}") RUST_RELEASE"
  exit 1
fi
RUST_RELEASE="${1}"

git clone --depth 1 --shallow-submodules --recurse-submodules --branch "${RUST_RELEASE}" git@github.com:rust-lang/rust.git

cd rust

patch --strip 1 --input ../rust.patch

cargo run --manifest-path src/ci/citool/Cargo.toml run-local dist-x86_64-linux
cargo run --manifest-path src/ci/citool/Cargo.toml run-local dist-various-2

mkdir ../rust-dist
cp obj/dist-x86_64-linux/build/dist/cargo-*-x86_64-unknown-linux-gnu.tar.xz ../rust-dist
cp obj/dist-x86_64-linux/build/dist/rustc-*-x86_64-unknown-linux-gnu.tar.xz ../rust-dist
cp obj/dist-x86_64-linux/build/dist/rust-std-*-x86_64-unknown-linux-gnu.tar.xz ../rust-dist
cp obj/dist-various-2/build/dist/rust-std-*-i586-unknown-freebsd.tar.xz ../rust-dist
