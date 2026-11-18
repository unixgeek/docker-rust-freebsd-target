#!/bin/sh -ex

CLANG_TRIPLE="${ARCH}-unknown-freebsd${FREEBSD_RELEASE}"
RUSTC_TRIPLE="${ARCH}-unknown-freebsd"
FREEBSD_BASE="/usr/local/freebsd-${FREEBSD_RELEASE}"
BUILD_DEPENDENCIES="curl xz-utils"

export DEBIAN_FRONTEND=noninteractive
apt-get update
# shellcheck disable=SC2086
apt-get install -y --no-install-recommends ${BUILD_DEPENDENCIES}

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

useradd --create-home rust

install_artifact() {
    ARTIFACT=$1
    tar -x -J -f /tmp/rust-obj/"${ARTIFACT}"
    DIR=$(basename "${ARTIFACT}" | sed 's/\.tar\.xz//')
    "${DIR}"/install.sh --prefix=/home/rust/.x86_64-unknown-linux-gnu-patched/
    rm -fr "${DIR}"
}

# For i586, use the custom toolchain and target.
if [ "${ARCH}" = "i586" ]; then
  install_artifact cargo-"${RUST_RELEASE}"-x86_64-unknown-linux-gnu.tar.xz
  install_artifact rustc-"${RUST_RELEASE}"-x86_64-unknown-linux-gnu.tar.xz
  install_artifact rust-std-"${RUST_RELEASE}"-x86_64-unknown-linux-gnu.tar.xz
  install_artifact rust-std-"${RUST_RELEASE}"-i586-unknown-freebsd.tar.xz
  chown -R rust:rust /home/rust/.x86_64-unknown-linux-gnu-patched
  su rust <<EOF
  curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain none -y
  . /home/rust/.cargo/env
  rustup toolchain link x86_64-unknown-linux-gnu-patched /home/rust/.x86_64-unknown-linux-gnu-patched
  rustup default x86_64-unknown-linux-gnu-patched
EOF
else
  curl https://sh.rustup.rs -sSf | su rust -c "sh -s -- --default-toolchain ${RUST_RELEASE} --profile minimal -y"
  su rust -c ". /home/rust/.cargo/env; rustup target add ${RUSTC_TRIPLE}"
fi

# Set the linker for Cargo.
su rust -c "cat >> /home/rust/.cargo/config.toml <<EOF
[target.${RUSTC_TRIPLE}]
linker = \"/usr/local/bin/${CLANG_TRIPLE}-clang\"
EOF"

# Script to set environment variables needed for cross compiling. This is useful to allow for running unit tests on
# the host before targeting the cross environment.
su rust -c "cat >> /home/rust/set-cross-compile-env.sh <<EOF
export CC_$(echo "${RUSTC_TRIPLE}" | sed s/-/_/g)=/usr/local/bin/${CLANG_TRIPLE}-clang
export CXX_$(echo "${RUSTC_TRIPLE}" | sed s/-/_/g)=/usr/local/bin/${CLANG_TRIPLE}-clang++
EOF"

chmod 777 /home/rust/.cargo

# Cleanup
# shellcheck disable=SC2086
apt-get purge -y ${BUILD_DEPENDENCIES}
apt-get autoremove --purge -y
rm -f /tmp/setup-cross-compile.sh
