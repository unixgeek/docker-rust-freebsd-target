FROM debian:buster-slim

ENV PATH=/root/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ADD x86_64-unknown-linux-gnu-patched.tar /root/x86_64-unknown-linux-gnu-patched
ADD rust-std-1.51.0-i586-unknown-freebsd.tar.xz /tmp

COPY cross-compile-setup.sh /root

RUN /root/cross-compile-setup.sh i586

CMD ["/bin/sh"]
