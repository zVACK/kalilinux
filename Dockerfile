FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# چالاککردنی پشتگیری 32-bit بۆ بەرنامەکانی Wine
RUN dpkg --add-architecture i386

# دابەزاندنی پاکێجە سەرەکییەکان بە شێوەیەکی سووک
RUN apt update && apt install -y --no-install-recommends \
    xrdp \
    xfce4 \
    xfce4-terminal \
    xorg \
    dbus-x11 \
    sudo \
    curl \
    wget \
    git \
    nano \
    net-tools \
    pulseaudio \
    pulseaudio-utils \
    wine \
    wine32:i386 \
    wine64 \
    firefox-esr \
    ca-certificates && \
    apt clean && rm -rf /var/lib/apt/lists/*

# دروستکردنی یوزەری Ameer لەگەڵ وشەی نهێنی 1234 و بەخشینی مۆڵەتی sudo
RUN useradd -m -s /bin/bash Ameer && \
    echo "Ameer:1234" | chpasswd && \
    usermod -aG sudo Ameer

# دیاریکردنی سێشنی XFCE بۆ یوزەری Ameer
RUN echo "startxfce4" > /home/Ameer/.xsession && chmod 700 /home/Ameer/.xsession
RUN chown -R Ameer:Ameer /home/Ameer

RUN sed -i 's/^allowed_users=.*/allowed_users=anybody/' /etc/X11/Xwrapper.config || echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config

# دروستکردنی machine-id بۆ DBus
RUN mkdir -p /var/run/dbus && dbus-uuidgen > /var/lib/dbus/machine-id

RUN sed -i 's/crypt_level=high/crypt_level=low/' /etc/xrdp/xrdp.ini && \
    sed -i 's/security_layer=negotiate/security_layer=rdp/' /etc/xrdp/xrdp.ini && \
    echo "exec startxfce4" > /etc/xrdp/startwm.sh && chmod +x /etc/xrdp/startwm.sh

RUN adduser xrdp ssl-cert

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
