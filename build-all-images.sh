#!/bin/bash -e

RUST_RELEASES=(1.51.0 1.52.1 1.53.0 1.54.0 1.55.0 1.56.1 1.57.0 1.58.0 1.59.0 1.60.0 1.61.0 1.62.1 1.63.0 1.64.0 1.65.0 1.66.0)
LATEST=${RUST_RELEASES[$((${#RUST_RELEASES[@]} - 1))]}
ARCHES="x86_64 i686 i586"

for ARCH in ${ARCHES}; do
    if [ "${ARCH}" == "i586" ]; then
      RUST_RELEASES=(1.51.0)
      LATEST=1.51.0
    fi

    for RELEASE in "${RUST_RELEASES[@]}"; do
        TAG="unixgeek2/rust-${ARCH}-freebsd:rust-${RELEASE}"
        echo "${TAG}"
        docker buildx build --progress tty \
                            --build-arg ARCH="${ARCH}" \
                            --build-arg RUST_RELEASE="${RELEASE}" \
                            --tag "${TAG}" .
    done
    docker image tag "unixgeek2/rust-${ARCH}-freebsd:rust-${LATEST}" "unixgeek2/rust-${ARCH}-freebsd:latest" 
done
