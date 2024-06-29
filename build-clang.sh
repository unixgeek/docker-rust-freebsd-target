#!/bin/sh -e

# When changing this, update the /usr/bin/cc symlink at the end of the script.
CLANG_RELEASE=17.0.6
BUILD_DEPENDENCIES="build-essential python3 curl cmake ccache git ninja-build"

export DEBIAN_FRONTEND=noninteractive
apt-get update
# shellcheck disable=SC2086
apt-get install -y --no-install-recommends ${BUILD_DEPENDENCIES}

# Download clang.
mkdir -p /tmp/llvm/build /tmp/clang /tmp/lld /tmp/libunwind /tmp/cmake /tmp/third-party
curl -L https://github.com/llvm/llvm-project/releases/download/llvmorg-${CLANG_RELEASE}/llvm-${CLANG_RELEASE}.src.tar.xz \
  | tar -x -J -C /tmp/llvm --strip-components 1 -f -
curl -L https://github.com/llvm/llvm-project/releases/download/llvmorg-${CLANG_RELEASE}/clang-${CLANG_RELEASE}.src.tar.xz \
  | tar -x -J -C /tmp/clang --strip-components 1 -f -
curl -L https://github.com/llvm/llvm-project/releases/download/llvmorg-${CLANG_RELEASE}/lld-${CLANG_RELEASE}.src.tar.xz \
  | tar -x -J -C /tmp/lld --strip-components 1 -f -
curl -L https://github.com/llvm/llvm-project/releases/download/llvmorg-${CLANG_RELEASE}/libunwind-${CLANG_RELEASE}.src.tar.xz \
  | tar -x -J -C /tmp/libunwind --strip-components 1 -f -
curl -L https://github.com/llvm/llvm-project/releases/download/llvmorg-${CLANG_RELEASE}/cmake-${CLANG_RELEASE}.src.tar.xz \
  | tar -x -J -C /tmp/cmake --strip-components 1 -f -
curl -L https://github.com/llvm/llvm-project/releases/download/llvmorg-${CLANG_RELEASE}/third-party-${CLANG_RELEASE}.src.tar.xz \
  | tar -x -J -C /tmp/third-party --strip-components 1 -f -

# Build and install clang.
cd /tmp/llvm/build
cmake \
  -DLLVM_ENABLE_PROJECTS="clang;lld" \
  -DCMAKE_BUILD_TYPE=MinSizeRel \
  -DLLVM_PARALLEL_LINK_JOBS=1 \
  -DLLVM_INCLUDE_BENCHMARKS=OFF \
  -DLLVM_CCACHE_BUILD=ON \
  -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON \
  -DLLVM_TARGETS_TO_BUILD=X86 \
  -DLLVM_LINK_LLVM_DYLIB=ON \
  -DLLVM_INSTALL_BINUTILS_SYMLINKS=ON -G "Ninja" ../
ninja
ninja install
cd /root
rm -fr /tmp/clang /tmp/lld /tmp/llvm /tmp/libunwind /tmp/cmake /tmp/third-party

# Cleanup
# shellcheck disable=SC2086
apt-get purge -y ${BUILD_DEPENDENCIES}
apt-get autoremove --purge -y
rm -f /tmp/build-clang.sh

# Set some symlinks.
ln -s /usr/local/bin/ld.lld /usr/bin/ld
ln -s /usr/local/bin/clang-17 /usr/bin/cc
