FROM unixgeek2/rust-x86_64-freebsd:latest

USER root
RUN apt-get update \
    && apt-get install --no-install-recommends -y libssl-dev

USER rust
ENV OPENSSL_DIR=/usr/local/freebsd-13.2/usr

ENTRYPOINT ["/bin/sh", "-c"]