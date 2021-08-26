# Docker Rust FreeBSD Target
This docker image is used to cross compile Rust code, targeting FreeBSD.

## Usage
1. Run unit tests using the default x86_64 Linux target.

       cargo test

2. Setup cross compile environment. If your project requires an external library, like OpenSSL, you may need to set some
environment variables.

       . /rust/set-cross-compile-env.sh
       export OPENSSL_DIR=/usr/local/freebsd-12.2/usr

3. Compile.

       cargo build --release --target i586-unknown-freebsd

## Building
### i686 and x86_64
The `Dockerfile` is used for i686 and x86_64 images. It has two optional build args:
* `ARCH`: The target architecture (i686 or x86_64). Default is x86_64.
* `RUST_RELEASE`: The release of Rust to install. Default is 1.54.0.
#### x86_64
    docker image build --tag rust-x86_64-freebsd .
#### i686
    docker image build --build-arg ARCH=i686 --tag rust-i686-freebsd .
### i586
Rust has the i686 and x86_64 toolchains available, but not i586. In order to provide an i586 toolchain, the 
`build-rust-i586.sh` script builds Rust from a forked repository that has been patched to support the i586 target. It is
currently release 1.51.0. Once the toolchain has been built, the `i586.Dockerfile` can be used to build the image. There
may be a technical reason the i586 toolchain is not available, but it works for my small projects.  

    ./build-rust-i586.sh
    docker image build --tag rust-i586-freebsd --file i586.Dockerfile .