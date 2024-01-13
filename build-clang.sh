#!/bin/sh -ex

CLANG_RELEASE=14.0.5
BUILD_DEPENDENCIES="build-essential python3 curl cmake"

export DEBIAN_FRONTEND=noninteractive
apt-get update
# shellcheck disable=SC2086
apt-get install -y --no-install-recommends ${BUILD_DEPENDENCIES}

# Download clang.
mkdir -p /tmp/llvm/build /tmp/clang /tmp/lld /tmp/libunwind
curl -L https://github.com/llvm/llvm-project/releases/download/llvmorg-${CLANG_RELEASE}/llvm-${CLANG_RELEASE}.src.tar.xz \
  | tar -x -J -C /tmp/llvm --strip-components 1 -f -
curl -L https://github.com/llvm/llvm-project/releases/download/llvmorg-${CLANG_RELEASE}/clang-${CLANG_RELEASE}.src.tar.xz \
  | tar -x -J -C /tmp/clang --strip-components 1 -f -
curl -L https://github.com/llvm/llvm-project/releases/download/llvmorg-${CLANG_RELEASE}/lld-${CLANG_RELEASE}.src.tar.xz \
  | tar -x -J -C /tmp/lld --strip-components 1 -f -
curl -L https://github.com/llvm/llvm-project/releases/download/llvmorg-${CLANG_RELEASE}/libunwind-${CLANG_RELEASE}.src.tar.xz \
  | tar -x -J -C /tmp/libunwind --strip-components 1 -f -

# Only required because the cmake download isn't available for this version.
curl -L https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-${CLANG_RELEASE}.tar.gz \
  | tar -x -z -C /tmp --strip-components 1 -f - llvm-project-llvmorg-${CLANG_RELEASE}/cmake
curl -L https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-${CLANG_RELEASE}.tar.gz \
  | tar -x -z -C /tmp --strip-components 1 -f - llvm-project-llvmorg-${CLANG_RELEASE}/third-party
cd /tmp/llvm/build

# todo Use this clang-14.0.5.src.tar.xz or clang-tools-extra-14.0.5.src.tar.xz

# Build and install clang.
cmake \
  -DLLVM_ENABLE_PROJECTS="clang;lld" \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_PARALLEL_LINK_JOBS=1 \
  -DLLVM_INSTALL_BINUTILS_SYMLINKS=ON -G "Unix Makefiles" ../
make -j "$(nproc)"
make install
cd /root
rm -fr /tmp/clang /tmp/lld /tmp/llvm /tmp/libunwind /tmp/cmake /tmp/third-party

# Cleanup
# shellcheck disable=SC2086
apt-get purge -y ${BUILD_DEPENDENCIES}
apt-get autoremove --purge -y
rm -f /tmp/build-clang.sh

# Set some symlinks.
ln -s /usr/local/bin/ld.lld /usr/bin/ld
ln -s /usr/local/bin/clang-14 /usr/bin/cc
