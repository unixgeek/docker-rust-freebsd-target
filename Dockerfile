FROM debian:bullseye-slim

ARG RUST_RELEASE=1.62.0
ARG GITHUB_KEY=github

COPY cross-compile-setup.sh /tmp
RUN /tmp/cross-compile-setup.sh

RUN mkdir /home/rust/.ssh
COPY ${GITHUB_KEY} /home/rust/.ssh
COPY compile.sh /home/rust

RUN apt-get update -y \
    && mkdir -p /usr/share/man/man1 \
    && dpkg --add-architecture arm64 \
    && apt-get update \
    && apt-get install -y git ssh musl-tools:arm64 \
    && chmod 0600 /home/rust/.ssh/${GITHUB_KEY} \
    && chown rust:rust /home/rust/.ssh/${GITHUB_KEY} /home/rust/compile.sh \
    && chmod 700 /home/rust/compile.sh

# Needed for unit tests to pass ... so stupid.
ENV TZ=America/Chicago

USER rust
WORKDIR /home/rust
ENV PATH=/home/rust/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
CMD ["/bin/bash"]