FROM debian:buster-slim

ENV PATH=/root/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ARG ARCH=x86_64

COPY cross-compile-setup.sh /root

RUN /root/cross-compile-setup.sh ${ARCH}

CMD ["/bin/sh"]
