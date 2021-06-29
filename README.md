# Docker Rust FreeBSD Target
This docker image is used to cross compile Rust code, targeting FreeBSD.

## Usage
1. Run unit tests using the default x86_64 Linux target.

       cargo test

2. Setup cross compile environment. If your project requires an external library, like OpenSSL, you may need to set some
environment variables.

       . /root/set-cross-compile-env.sh
       export OPENSSL_DIR=/usr/local/freebsd-12.2/usr

3. Compile.

       cargo build --release --target i586-unknown-freebsd

## Building
This project supports three architectures: i586, i686, and x86_64.
### i686 and x86_64
The `Dockerfile` is parameterized such that you can specify which architecture to build with the `ARCH` ARG. The default
is x86_64.

    docker image build -t rust-i686-freebsd --build-arg ARCH=i686 .
or

    docker image build -t rust-x86_64-freebsd --build-arg ARCH=x86_64 .

### i586
Building for i586 requires running the `build-rust-i586.sh` script to build the i586 toolchain and then building the 
image using `i586.Dockerfile`. Rust has the i686 and x86_64 toolchains available, but not i586. There may be a technical
reason it isn't available, but the project I have targeting i586 works. 

    ./build-rust-i586.sh
    docker image build -t rust-i586-freebsd -f i586.Dockerfile .