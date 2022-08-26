#!/bin/bash -e

RUST_RELEASES=(1.51.0 1.52.1 1.53.0 1.54.0 1.55.0 1.56.1 1.57.0 1.58.0 1.59.0 1.60.0 1.61.0 1.62.1 1.63.0 1.64.0 1.65.0)
LATEST=${RUST_RELEASES[$((${#RUST_RELEASES[@]} - 1))]}
ARCHES="x86_64 i686"

for ARCH in ${ARCHES}; do
    for RELEASE in "${RUST_RELEASES[@]}"; do
        TAG="unixgeek2/rust-${ARCH}-freebsd:rust-${RELEASE}"
        docker buildx build --build-arg ARCH="${ARCH}" \
                            --build-arg RUST_RELEASE="${RELEASE}" \
                            --tag "${TAG}" .
        docker push "${TAG}"
    done
    docker image tag "unixgeek2/rust-${ARCH}-freebsd:rust-${LATEST}" "unixgeek2/rust-${ARCH}-freebsd:latest" 
    docker push "unixgeek2/rust-${ARCH}-freebsd:latest"
done

docker buildx build --build-arg ARCH=i586 --build-arg RUST_RELEASE=1.51.0 --tag unixgeek2/rust-i586-freebsd:rust-1.51.0 .
docker push unixgeek2/rust-i586-freebsd:rust-1.51.0
docker image tag unixgeek2/rust-i586-freebsd:rust-1.51.0 unixgeek2/rust-i586-freebsd:latest
docker push unixgeek2/rust-i586-freebsd:latest
