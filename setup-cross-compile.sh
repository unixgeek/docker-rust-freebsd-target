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

groupadd -r rust -g 2000
useradd -m -r -g rust -u 2000 rust

install_artifact() {
    ARTIFACT=$1
    curl "${ARTIFACT}" | tar -x -J -f -
    DIR=$(basename "${ARTIFACT}" | sed 's/\.tar\.xz//')
    "${DIR}"/./install.sh --prefix=/home/rust/.x86_64-unknown-linux-gnu-patched/
    rm -fr "${DIR}"
}

# For i586, use the custom toolchain and target.
if [ "${ARCH}" = "i586" ]; then
  install_artifact https://f004.backblazeb2.com/file/rust-freebsd/cargo-1.51.0-x86_64-unknown-linux-gnu.tar.xz
  install_artifact https://f004.backblazeb2.com/file/rust-freebsd/clippy-1.51.0-x86_64-unknown-linux-gnu.tar.xz
  install_artifact https://f004.backblazeb2.com/file/rust-freebsd/rust-std-1.51.0-i586-unknown-freebsd.tar.xz
  install_artifact https://f004.backblazeb2.com/file/rust-freebsd/rust-std-1.51.0-x86_64-unknown-linux-gnu.tar.xz
  install_artifact https://f004.backblazeb2.com/file/rust-freebsd/rustc-1.51.0-x86_64-unknown-linux-gnu.tar.xz
  install_artifact https://f004.backblazeb2.com/file/rust-freebsd/rustfmt-1.51.0-x86_64-unknown-linux-gnu.tar.xz
  chown -R rust:rust /home/rust/.x86_64-unknown-linux-gnu-patched
  su rust <<EOF
  curl https://sh.rustup.rs -sSf | /bin/sh -s -- --default-toolchain none -y
  . /home/rust/.cargo/env
  rustup toolchain link x86_64-unknown-linux-gnu-patched /home/rust/.x86_64-unknown-linux-gnu-patched
  rustup default x86_64-unknown-linux-gnu-patched
EOF
else
  curl https://sh.rustup.rs -sSf | su rust -c "sh -s -- --default-toolchain ${RUST_RELEASE} -y"
  su rust -c ". /home/rust/.cargo/env; rustup target add ${RUSTC_TRIPLE}"
  # Don't see a method to avoid installing this component.
  su rust -c ". /home/rust/.cargo/env; rustup component remove rust-docs"
fi

# Set the linker for Cargo.
su rust -c "cat >> /home/rust/.cargo/config <<EOF
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
rm -f /tmp/cross-compile-setup.sh
