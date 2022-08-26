#!/bin/sh -e

# This should allow for running as a user that isn't root, but also might not be rust.
HOME=/home/rust
. /home/rust/.cargo/env
. /home/rust/set-cross-compile-env.sh
exec cargo "$@"
