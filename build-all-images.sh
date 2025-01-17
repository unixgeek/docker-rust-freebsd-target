#!/bin/bash -e

RUST_RELEASES=(75.0 76.0 77.2 78.0 79.0 80.1 81.0 82.0 83.0 84.0)
LATEST=1.${RUST_RELEASES[$((${#RUST_RELEASES[@]} - 1))]}
ARCHES="x86_64 i686 i586"

for ARCH in ${ARCHES}; do
  if [ "${ARCH}" == "i586" ]; then
    RUST_RELEASES=(51.0)
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
