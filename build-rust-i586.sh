#!/bin/sh -e

git clone --depth 1 --branch 1.51.0-i586-freebsd --recurse-submodules https://github.com/unixgeek/rust.git

mkdir dist

cd rust

# Won't work on certain kernels: https://github.com/moby/moby/issues/28705#issuecomment-262226229
./src/ci/docker/run.sh dist-x86_64-linux

mv obj/build/dist/cargo-1.51.0-x86_64-unknown-linux-gnu.tar.xz ../dist
mv obj/build/dist/clippy-1.51.0-x86_64-unknown-linux-gnu.tar.xz ../dist
mv obj/build/dist/rust-std-1.51.0-x86_64-unknown-linux-gnu.tar.xz ../dist
mv obj/build/dist/rustc-1.51.0-x86_64-unknown-linux-gnu.tar.xz ../dist
mv obj/build/dist/rustfmt-1.51.0-x86_64-unknown-linux-gnu.tar.xz ../dist

# Rust docs advise on cleaning this directory between builds.
rm -fr obj/*

./src/ci/docker/run.sh dist-various-2

mv obj/build/dist/rust-std-1.51.0-i586-unknown-freebsd.tar.xz ../dist

cd ../
