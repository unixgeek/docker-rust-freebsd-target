FROM debian:bullseye-slim

# The i586 image requires a patched version of rust, so we're currently stuck at 1.51.0
ARG RUST_RELEASE=1.51.0

ADD x86_64-unknown-linux-gnu-patched.tar /tmp/x86_64-unknown-linux-gnu-patched
ADD rust-std-1.51.0-i586-unknown-freebsd.tar.xz /tmp

COPY cross-compile-setup.sh /tmp

RUN /tmp/cross-compile-setup.sh i586

USER rust
ENV PATH=/home/rust/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
CMD ["/bin/sh"]
