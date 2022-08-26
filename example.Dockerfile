FROM unixgeek2/rust-x86_64-freebsd:rust-1.65.0

USER root
RUN apt-get update \
    && apt-get install --no-install-recommends -y libssl-dev

USER rust
ENV OPENSSL_DIR=/usr/local/freebsd-12.3/usr

ENTRYPOINT ["/bin/sh", "-c"]