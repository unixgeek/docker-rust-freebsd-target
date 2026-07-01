#!/bin/bash -e

RUST_RELEASES=(87.0 88.0 89.0 90.0 91.1 92.0 93.1 94.1 95.0 96.0)
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
