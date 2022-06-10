FROM debian:bullseye-slim

COPY build-clang.sh /tmp
RUN /tmp/build-clang.sh

ARG ARCH=x86_64
ARG RUST_RELEASE=1.61.0

COPY cross-compile-setup.sh /tmp
RUN /tmp/cross-compile-setup.sh ${ARCH}

USER rust
ENV PATH=/home/rust/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
CMD ["/bin/sh"]