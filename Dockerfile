ARG BUILD_FROM=ghcr.io/home-assistant/base:latest
FROM ${BUILD_FROM}

# Home Assistant Labels
LABEL \
    io.hass.name="CUPS+foo2zjs Print Server" \
    io.hass.description="CUPS Druckserver und selbst kompilierter foo2zjs Treiber für Home Assistant" \
    io.hass.arch="amd64|aarch64" \
    io.hass.type="addon" \
    io.hass.version="1.0.0"

RUN apk update && apk add --no-cache \
    # System & Shell
    bash \
    bash-completion \
    procps \
    nano \
    sudo \
    openssl \
    gnupg \
    xz \
    curl \
    # Build & Git
    build-base \
    git \
    lsb-release \
    # CUPS Kern
    cups \
    cups-libs \
    cups-filters \
    # Treiber & Rendering (Alternative zu foomatic-db)
    ghostscript \
    gutenprint \
    # Die tatsächlichen PPD-Dateien und Filter
    cups-filters-libs \
    # Netzwerk & Discovery
    avahi \
    avahi-compat-libdns_sd \
    dbus \
    dbus-libs \
    whois \
    colord \
    && rm -rf /var/cache/apk/*

RUN git clone https://github.com/mikerr/foo2zjs.git /tmp/foo2zjs \
    && cd /tmp/foo2zjs \
    && make \
    && make install \
    && rm -rf /tmp/foo2zjs

RUN mkdir -p /var/run/dbus && chown messagebus:messagebus /var/run/dbus

COPY rootfs /

# User anlegen und Gruppen-Zuweisung reparieren
RUN adduser -D -h /home/print -s /bin/bash print \
    && addgroup -S sudo 2>/dev/null || true \
    && addgroup -S lpadmin 2>/dev/null || true \
    && addgroup print sudo \
    && addgroup print lp \
    && addgroup print lpadmin \
    && echo "print:$(openssl passwd -6 print)" | chpasswd -e \
    && mkdir -p /etc/sudoers.d \
    && echo "print ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/print \
    && chmod 0440 /etc/sudoers.d/print

EXPOSE 631

RUN chmod a+x /run.sh

CMD ["/run.sh"]
