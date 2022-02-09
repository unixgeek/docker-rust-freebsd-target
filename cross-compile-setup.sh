#!/bin/sh -ex

CLANG_TRIPLE="aarch64-unknown-linux-gnu"
RUSTC_TRIPLE="aarch64-unknown-linux-gnu"
BUILD_DEPENDENCIES="curl ca-certificates xz-utils"

export DEBIAN_FRONTEND=noninteractive
apt-get update
# shellcheck disable=SC2086
apt-get install -y --no-install-recommends ${BUILD_DEPENDENCIES}

# gcc-10-base:arm64?

# Create cross compile wrapper scripts for clang.
cat >> "/usr/local/bin/${CLANG_TRIPLE}-clang" <<EOF
#!/bin/sh
/usr/local/bin/clang "\$@" --target=${CLANG_TRIPLE}
EOF
cat >> "/usr/local/bin/${CLANG_TRIPLE}-clang++" <<EOF
#!/bin/sh
/usr/local/bin/clang++ "\$@" --target=${CLANG_TRIPLE}
EOF
chmod 755 "/usr/local/bin/${CLANG_TRIPLE}-clang" "/usr/local/bin/${CLANG_TRIPLE}-clang++"

groupadd -r rust
useradd -m -r -g rust rust

curl https://sh.rustup.rs -sSf | su rust -c "sh -s -- --default-toolchain ${RUST_RELEASE} -y"
su rust -c ". /home/rust/.cargo/env; rustup target add ${RUSTC_TRIPLE}"

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

# Cleanup
# shellcheck disable=SC2086
apt-get purge -y ${BUILD_DEPENDENCIES} python2
apt autoremove --purge -y
rm -fr /var/lib/apt/lists/*
rm -f /tmp/cross-compile-setup.sh
