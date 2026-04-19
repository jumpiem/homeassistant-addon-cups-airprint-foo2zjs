ARG BUILD_FROM=ghcr.io/home-assistant/base:latest
FROM ${BUILD_FROM}

LABEL maintainer="jumpiem@gmail.com" \
      version="1.0" \
      description="Home Assistant Add-on mit CUPS und selbst kompiliertem foo2zjs Treiber"

RUN apk update && apk add --no-cache \
    bash \
    build-base \
    cups \
    cups-dev \
    git \
    avahi \
    dbus \
    colord \
    sudo \
    samba \
    bash-completion \
    procps \
    nano \
    gnupg \
    lsb-release \
    whois \
    cups-filters \
    && rm -rf /var/cache/apk/*

RUN git clone https://github.com/mikerr/foo2zjs.git /tmp/foo2zjs \
    && cd /tmp/foo2zjs \
    && make \
    && make install \
    && rm -rf /tmp/foo2zjs

COPY rootfs /

# Add user and disable sudo password checking
RUN useradd \
  --groups=sudo,lp,lpadmin \
  --create-home \
  --home-dir=/home/print \
  --shell=/bin/bash \
  --password=$(mkpasswd print) \
  print \
&& sed -i '/%sudo[[:space:]]/ s/ALL[[:space:]]*$/NOPASSWD:ALL/' /etc/sudoers

EXPOSE 631

RUN chmod a+x /run.sh

CMD ["/run.sh"]
