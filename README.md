# Docker Rust FreeBSD Target
This docker image is used to cross compile Rust code, targeting FreeBSD.

## Usage
1. Run unit tests using the default x86_64 Linux target.

       cargo test

2. Setup cross compile environment. If your project requires an external library, like OpenSSL, you may need to set some
environment variables.

       . /home/rust/set-cross-compile-env.sh
       export OPENSSL_DIR=/usr/local/freebsd-12.3/usr

3. Compile.
   - For the x86_64 image:

         cargo build --release --target x86_64-unknown-freebsd
   - For the i686 image:

         cargo build --release --target i686-unknown-freebsd
   - For the i586 image:

         cargo build --release --target i586-unknown-freebsd

## Building
There are two optional build args:
* `ARCH`: The target architecture (i586, i686 or x86_64). Default is x86_64.
* `RUST_RELEASE`: The release of Rust to install. Default is 1.58.1.
### x86_64
    docker image build --tag rust-x86_64-freebsd .
### i686
    docker image build --build-arg ARCH=i686 --tag rust-i686-freebsd .
### i586
    docker image build --build-arg ARCH=i586 --build-arg RUST_RELEASE=1.51.0 -t rust-i586-freebsd .
Note that `RUST_RELEASE` must be 1.51.0 for i586. See below.
#### i586 Artifacts
Rust has the i686 and x86_64 toolchains available, but not i586. In order to provide an i586 toolchain, the
`build-rust-i586.sh` script builds Rust from a forked repository that has been patched to support the i586 target. It is
currently release 1.51.0. These artifacts have been uploaded to a server to be made available to the build.
There may be a technical reason the i586 toolchain is not available, but it works for my small
projects. 
