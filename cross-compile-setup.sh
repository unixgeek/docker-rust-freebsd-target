#!/bin/sh -e

if [ $# -ne 1 ]; then
  echo "usage: $(basename "$0") TARGET(i586|i686|x86_64)"
  exit 1
fi

set -x

FREEBSD_RELEASE=12.3
CLANG_RELEASE=10.0.1
ARCH="${1}"
CLANG_TRIPLE="${ARCH}-unknown-freebsd${FREEBSD_RELEASE}"
RUSTC_TRIPLE="${ARCH}-unknown-freebsd"
FREEBSD_BASE="/usr/local/freebsd-${FREEBSD_RELEASE}"
BUILD_DEPENDENCIES="build-essential python curl cmake ca-certificates"

# Determine the arch for downloading the FreeBSD base system.
case ${ARCH} in
"i586") RELEASE_ARCH="i386";;
"i686") RELEASE_ARCH="i386";;
"x86_64") RELEASE_ARCH="amd64";;
esac

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y
# shellcheck disable=SC2086
apt-get install -y --no-install-recommends ${BUILD_DEPENDENCIES} libgcc-10-dev

# Extract needed includes and libs from the FreeBSD base package.
mkdir "${FREEBSD_BASE}"
curl -L ftp://ftp.freebsd.org/pub/FreeBSD/releases/${RELEASE_ARCH}/${FREEBSD_RELEASE}-RELEASE/base.txz \
  | tar -x -J -C "${FREEBSD_BASE}" ./usr/include ./usr/lib ./lib -f -

# Download clang.
mkdir -p /tmp/llvm/build /tmp/clang /tmp/lld
curl -L https://github.com/llvm/llvm-project/releases/download/llvmorg-${CLANG_RELEASE}/llvm-${CLANG_RELEASE}.src.tar.xz \
  | tar -x -J -C /tmp/llvm --strip-components 1 -f -
curl -L https://github.com/llvm/llvm-project/releases/download/llvmorg-${CLANG_RELEASE}/clang-${CLANG_RELEASE}.src.tar.xz \
  | tar -x -J -C /tmp/clang --strip-components 1 -f -
curl -L https://github.com/llvm/llvm-project/releases/download/llvmorg-${CLANG_RELEASE}/lld-${CLANG_RELEASE}.src.tar.xz \
  | tar -x -J -C /tmp/lld --strip-components 1 -f -
cd /tmp/llvm/build

# Build and install clang.
cmake \
  -DLLVM_ENABLE_PROJECTS="clang;lld" \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_PARALLEL_LINK_JOBS=1 \
  -DLLVM_INSTALL_BINUTILS_SYMLINKS=ON -G "Unix Makefiles" ../
make -j "$(nproc)"
make install
cd /root
rm -fr /tmp/clang /tmp/lld /tmp/llvm

# Create cross compile wrapper scripts for clang.
cat >> "/usr/local/bin/${CLANG_TRIPLE}-clang" <<EOF
#!/bin/sh
/usr/local/bin/clang --sysroot=${FREEBSD_BASE} "\$@" --target=${CLANG_TRIPLE}
EOF
cat >> "/usr/local/bin/${CLANG_TRIPLE}-clang++" <<EOF
#!/bin/sh
/usr/local/bin/clang++ --sysroot=${FREEBSD_BASE} "\$@" --target=${CLANG_TRIPLE}
EOF
chmod 755 "/usr/local/bin/${CLANG_TRIPLE}-clang" "/usr/local/bin/${CLANG_TRIPLE}-clang++"

groupadd -r rust
useradd -m -r -g rust rust

# For i586, use the custom toolchain and target.
if [ "${ARCH}" = "i586" ]; then
  mv /tmp/x86_64-unknown-linux-gnu-patched /home/rust
  chown -R rust:rust /home/rust/x86_64-unknown-linux-gnu-patched
  curl https://sh.rustup.rs -sSf | su rust -c "sh -s -- -y"
  su rust -c ". /home/rust/.cargo/env; rustup toolchain link x86_64-unknown-linux-gnu-patched /home/rust/x86_64-unknown-linux-gnu-patched"
  su rust -c ". /home/rust/.cargo/env; rustup default x86_64-unknown-linux-gnu-patched"
  su rust -c ". /home/rust/.cargo/env;/tmp/rust-std-${RUST_RELEASE}-i586-unknown-freebsd/install.sh --prefix=/home/rust/.rustup/toolchains/x86_64-unknown-linux-gnu-patched"
  rm -fr /tmp/rust-std-"${RUST_RELEASE}"-i586-unknown-freebsd
else
  curl https://sh.rustup.rs -sSf | su rust -c "sh -s -- --default-toolchain ${RUST_RELEASE} -y"
  su rust -c ". /home/rust/.cargo/env; rustup target add ${RUSTC_TRIPLE}"
fi

# Set the linker for Cargo.
su rust -c cat >> "/home/rust/.cargo/config" <<EOF
[target.${RUSTC_TRIPLE}]
linker = "/usr/local/bin/${CLANG_TRIPLE}-clang"
EOF

# Script to set environment variables needed for cross compiling. This is useful to allow for running unit tests on
# the host before targeting the cross environment.
su rust -c cat >> "/home/rust/set-cross-compile-env.sh" <<EOF
export CC_$(echo "${RUSTC_TRIPLE}" | sed s/-/_/g)=/usr/local/bin/${CLANG_TRIPLE}-clang
export CXX_$(echo "${RUSTC_TRIPLE}" | sed s/-/_/g)=/usr/local/bin/${CLANG_TRIPLE}-clang++
EOF

# Cleanup
# shellcheck disable=SC2086
apt-get purge -y ${BUILD_DEPENDENCIES} python2
apt autoremove --purge -y
rm -fr /var/lib/apt/lists/*
rm /tmp/cross-compile-setup.sh

# Set some symlinks.
ln -s /usr/local/bin/ld.lld /usr/bin/ld
ln -s /usr/local/bin/clang-10 /usr/bin/cc