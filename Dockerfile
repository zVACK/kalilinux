FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386

RUN apt update && apt install -y \
    xfce4 \
    xfce4-goodies \
    xorg \
    dbus-x11 \
    sudo \
    curl \
    wget \
    nano \
    net-tools \
    polkitd \
    pkexec \
    pipewire-pulse \
    pulseaudio-utils \
    wine \
    wine32 \
    firefox-esr && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Set root password
RUN echo "root:root" | chpasswd

# دروستکردنی یوزەری Ameer و دانانی پاسۆرد
RUN useradd -m -s /bin/bash Ameer && \
    echo "Ameer:123456" | chpasswd && \
    usermod -aG sudo Ameer

RUN echo "startxfce4" > /home/Ameer/.xsession && \
    chown Ameer:Ameer /home/Ameer/.xsession && \
    chmod 700 /home/Ameer/.xsession

# Generate machine-id for dbus
RUN mkdir -p /var/run/dbus && dbus-uuidgen > /var/lib/dbus/machine-id

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
