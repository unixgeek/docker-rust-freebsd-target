#!/bin/bash -e

RUST_RELEASES=(98.1)
LATEST=1.${RUST_RELEASES[$((${#RUST_RELEASES[@]} - 1))]}
ARCHES="x86_64 i686 i586"

for ARCH in ${ARCHES}; do
  for RELEASE in "${RUST_RELEASES[@]}"; do
    TAG="unixgeek2/rust-${ARCH}-freebsd:rust-1.${RELEASE}"
    echo "${TAG}"
    docker buildx build --progress tty \
                        --sbom=true --provenance=mode=max \
                        --build-arg ARCH="${ARCH}" \
                        --build-arg RUST_RELEASE="1.${RELEASE}" \
                        --push \
                        --tag "${TAG}" .
  done
  docker buildx build --progress tty \
                      --sbom=true --provenance=mode=max \
                      --build-arg ARCH="${ARCH}" \
                      --build-arg RUST_RELEASE="${LATEST}" \
                      --push \
                      --tag "unixgeek2/rust-${ARCH}-freebsd:latest" .
done
