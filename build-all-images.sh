#!/bin/bash -e

RUST_RELEASES=(51.0 52.1 53.0 54.0 55.0 56.1 57.0 58.1 59.0 60.0 61.0 62.1 63.0 64.0 65.0 66.1 67.0)
LATEST=1.${RUST_RELEASES[$((${#RUST_RELEASES[@]} - 1))]}
ARCHES="x86_64 i686 i586"

for ARCH in ${ARCHES}; do
    if [ "${ARCH}" == "i586" ]; then
      RUST_RELEASES=(1.51.0)
      LATEST=1.51.0
    fi

    for RELEASE in "${RUST_RELEASES[@]}"; do
        TAG="unixgeek2/rust-${ARCH}-freebsd:rust-1.${RELEASE}"
        echo "${TAG}"
        docker buildx build --progress tty \
                            --build-arg ARCH="${ARCH}" \
                            --build-arg RUST_RELEASE="1.${RELEASE}" \
                            --tag "${TAG}" .
    done
    docker image tag "unixgeek2/rust-${ARCH}-freebsd:rust-${LATEST}" "unixgeek2/rust-${ARCH}-freebsd:latest" 
done
