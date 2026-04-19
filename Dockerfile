ARG BUILD_FROM=ghcr.io/home-assistant/base:latest
FROM ${BUILD_FROM}

LABEL maintainer="jumpiem@gmail.com" \
      version="1.0" \
      description="Home Assistant Add-on mit CUPS und selbst kompiliertem foo2zjs Treiber"

RUN apk update && apk add --no-cache \
    sudo \
    openssl \
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

# Gruppen erstellen (lpadmin existiert oft nicht standardmäßig)
RUN addgroup -S lpadmin 2>/dev/null || true

# User hinzufügen und Passwort setzen
# -D: Kein Passwort erzwingen (wird danach per chpasswd gesetzt)
# -s: Shell festlegen
# -h: Home-Verzeichnis
# -G: Zusätzliche Gruppen (lp, sudo, lpadmin)
RUN adduser -D -h /home/print -s /bin/bash print \
    && addgroup print sudo \
    && addgroup print lp \
    && addgroup print lpadmin \
    && echo "print:$(openssl passwd -6 print)" | chpasswd -e \
    && echo "print ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/print \
    && chmod 0440 /etc/sudoers.d/print

EXPOSE 631

RUN chmod a+x /run.sh

CMD ["/run.sh"]
