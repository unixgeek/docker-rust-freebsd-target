# Docker Rust FreeBSD Target ![Docker Image Version (latest by date)](https://img.shields.io/docker/v/unixgeek2/rust-x86_64-freebsd)
This Docker image is used to cross-compile Rust for FreeBSD.

## Usage
### General Example
In the directory containing your project run:
```shell
    docker container run --rm --volume "$(pwd)":/src     \
        --user "$(id --user):$(id --group)" \
        "unixgeek2/rust-x86_64-freebsd:latest"      \
        build --release --target x86_64-unknown-freebsd
```
### GitHub Action Example
This example works out of the box in a run step with the ubuntu runner.
```shell
    docker container run --rm
        --volume ${{ github.workspace }}:/src
        --user $(id --user):$(id --group)
        unixgeek2/rust-x86_64-freebsd:latest build --release --target x86_64-unknown-freebsd
```
### Using as a Base Image
```dockerfile
FROM unixgeek2/rust-x86_64-freebsd:latest
USER root
RUN apt-get update \
    && apt-get install --no-install-recommends -y libssl-dev
USER rust
ENTRYPOINT ["/bin/sh", "-c"]
```
## Docker Hub
* [x86_64](https://hub.docker.com/r/unixgeek2/rust-x86_64-freebsd)
* [i686](https://hub.docker.com/r/unixgeek2/rust-i686-freebsd)
* [i586](https://hub.docker.com/r/unixgeek2/rust-i586-freebsd)
## Building
There are two optional build args:
* `ARCH`: The target architecture (i586, i686 or x86_64). The default is x86_64.
* `RUST_RELEASE`: The release of Rust to install. Check `Dockerfile` for the default.
### x86_64
```shell
docker buildx build --tag rust-x86_64-freebsd .
```
### i686
```shell
docker buildx build --build-arg ARCH=i686 --tag rust-i686-freebsd .
```
### i586
```shell
./build-rust-i586.sh 1.97.1
docker buildx build --build-arg ARCH=i586 --build-arg RUST_RELEASE=1.97.1 --tag rust-i586-freebsd .
```
