#!/bin/sh -e

git clone --depth 1 --branch 1.51.0-i586-freebsd --recurse-submodules https://github.com/unixgeek/rust.git

cd rust

# Won't work on certain kernels: https://github.com/moby/moby/issues/28705#issuecomment-262226229
./src/ci/docker/run.sh dist-x86_64-linux

tar -c -f ../x86_64-unknown-linux-gnu-patched.tar -C obj/build/x86_64-unknown-linux-gnu/stage2 .

# Rust docs advise on cleaning this directory between builds.
rm -fr obj/*

./src/ci/docker/run.sh dist-various-2

cp obj/build/dist/rust-std-1.51.0-i586-unknown-freebsd.tar.xz ../

cd ../
