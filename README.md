# Docker Rust FreeBSD Target
This Docker image is used to cross compile Rust for FreeBSD.

## Usage
### General Example
In the directory containing your project run:

    docker container run --rm --volume "$(pwd)":/src     \
        --init --tty --user "$(id --user):$(id --group)" \
        "unixgeek2/rust-x86_64-freebsd:rust-1.66.0"      \
        build --release --target x86_64-unknown-freebsd

If you need to provide environment variables for linking to external libraries, like OpenSSL, then use the `--env` parameter.

    docker container run --rm --volume "$(pwd)":/src     \
        --init --tty --user "$(id --user):$(id --group)" \
        --env OPENSSL_DIR=/usr/local/freebsd-13.1/usr    \
        "unixgeek2/rust-x86_64-freebsd:rust-1.66.0"      \
        build --release --target x86_64-unknown-freebsd

### GitHub Action Example
This example works out of the box in a run step with the ubuntu runner.

    docker container run --rm
        --volume ${{ github.workspace }}:/src
        --user $(id --user):$(id --group)
        --env OPENSSL_DIR=/usr/local/freebsd-13.1/usr
        unixgeek2/rust-x86_64-freebsd:rust-1.66.0 build --release --target x86_64-unknown-freebsd

### Using as a Base Image

    FROM unixgeek2/rust-x86_64-freebsd:rust-1.66.0
    USER root
    RUN apt-get update \
        && apt-get install --no-install-recommends -y libssl-dev
    USER rust
    ENV OPENSSL_DIR=/usr/local/freebsd-13.1/usr
    ENTRYPOINT ["/bin/sh", "-c"]

## Building
There are two optional build args:
* `ARCH`: The target architecture (i586, i686 or x86_64). Default is x86_64.
* `RUST_RELEASE`: The release of Rust to install. Check `Dockerfile` for the default.
### x86_64
    docker buildx build --tag rust-x86_64-freebsd .
### i686
    docker buildx build --build-arg ARCH=i686 --tag rust-i686-freebsd .
### i586
    docker buildx build --build-arg ARCH=i586 --build-arg RUST_RELEASE=1.51.0 --tag rust-i586-freebsd .
Note that `RUST_RELEASE` must be 1.51.0 for i586. See below.
#### i586 Artifacts
Rust has the i686 and x86_64 toolchains available, but not i586. In order to provide an i586 toolchain, the
`build-rust-i586.sh` script builds Rust from a forked repository that has been patched to support the i586 target. It is
currently release 1.51.0. These artifacts have been uploaded to a server to be made available to the build.
There may be a technical reason the i586 toolchain is not available, but it works for my small
projects. 
