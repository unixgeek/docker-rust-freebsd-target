#!/bin/bash -e

if [ $# -ne 1 ]; then
  echo "usage: $(basename "${0}") RUST_RELEASE"
  exit 1
fi
RUST_RELEASE="${1}"

if [ ! -e rust ]; then
  ./build-rust-i586.sh "${RUST_RELEASE}"
fi

docker buildx use rust-freebsd-builder 2>/dev/null || docker buildx create --name rust-freebsd-builder --bootstrap --use

ARCHES="x86_64 i686 i586"
for ARCH in ${ARCHES}; do
  TAG="unixgeek2/rust-${ARCH}-freebsd:rust-${RUST_RELEASE}"
  echo "${TAG}"

  # rust release tag
  docker buildx build --progress tty \
                      --sbom=true --provenance=mode=max \
                      --build-arg ARCH="${ARCH}" \
                      --build-arg RUST_RELEASE="${RUST_RELEASE}" \
                      --push \
                      --tag "${TAG}" .

  # latest tag
  docker image tag "${TAG}" "unixgeek2/rust-${ARCH}-freebsd:latest"
  docker image push "unixgeek2/rust-${ARCH}-freebsd:latest"
done
