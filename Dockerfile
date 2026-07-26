FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386

# دابەزاندنی پرۆگرامە ڕەسەنەکانی Debian Trixie لەگەڵ Picom
RUN apt update && apt install -y \
    xrdp \
    xfce4 \
    xfce4-goodies \
    xfce4-terminal \
    xorg \
    dbus-x11 \
    sudo \
    curl \
    wget \
    git \
    nano \
    vim \
    htop \
    fastfetch \
    net-tools \
    polkitd \
    pkexec \
    pipewire-pulse \
    pulseaudio-utils \
    pavucontrol \
    wine \
    wine32 \
    firefox-esr \
    chromium \
    vlc \
    gimp \
    libreoffice \
    filezilla \
    unzip \
    zip \
    build-essential \
    picom \
    fonts-noto-color-emoji && \
    apt clean && rm -rf /var/lib/apt/lists/*

# دروستکردنی یوزەری Ameer
RUN useradd -m -s /bin/bash Ameer && \
    echo "Ameer:123456" | chpasswd && \
    usermod -aG sudo Ameer

# دروستکردنی فۆڵدەرەکانی ڕێکخستن و Autostart
RUN mkdir -p /home/Ameer/.config/picom /home/Ameer/.config/gtk-3.0 /home/Ameer/.config/autostart && \
    chown -R Ameer:Ameer /home/Ameer/.config

# ڕێکخستنی Picom بۆ کاریگەری شووشەیی (Glass effect)
RUN echo 'backend = "xrender";\n\
active-opacity = 0.90;\n\
inactive-opacity = 0.85;\n\
frame-opacity = 0.80;' > /home/Ameer/.config/picom/picom.conf

# دروستکردنی CSS بۆ لایەوتی Glass لەسەر تێمی ڕەسەن
RUN echo 'panel.gtk-gradient, .xfce4-panel {\n\
    background-color: rgba(30, 30, 30, 0.60);\n\
}\n\
window {\n\
    background-color: rgba(25, 25, 25, 0.85);\n\
}' > /home/Ameer/.config/gtk-3.0/gtk.css

# کارپێکردنی Picom لە ناو Autostartی خودی XFCE (بۆ ڕێگری لە Crash)
RUN echo '[Desktop Entry]\n\
Type=Application\n\
Name=Picom Glass Effect\n\
Exec=picom --config /home/Ameer/.config/picom/picom.conf -b\n\
OnlyShowIn=XFCE;' > /home/Ameer/.config/autostart/picom.desktop

RUN chown -R Ameer:Ameer /home/Ameer/.config

# دیاریکردنی .xsession بە شێوازی زۆر خاوێن
RUN echo "startxfce4" > /home/Ameer/.xsession && \
    chown Ameer:Ameer /home/Ameer/.xsession && \
    chmod 755 /home/Ameer/.xsession

RUN sed -i 's/^allowed_users=.*/allowed_users=anybody/' /etc/X11/Xwrapper.config || echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config

# ڕێکخستنی ڕەسەنی xRDP تا بە هیچ شێوەیەک Sessionەکەت هەڵە نەدات
RUN sed -i 's/crypt_level=high/crypt_level=low/' /etc/xrdp/xrdp.ini && \
    sed -i 's/security_layer=negotiate/security_layer=rdp/' /etc/xrdp/xrdp.ini && \
    echo "#!/bin/sh" > /etc/xrdp/startwm.sh && \
    echo "test -x /etc/X11/Xsession && exec /etc/X11/Xsession" >> /etc/xrdp/startwm.sh && \
    echo "exec startxfce4" >> /etc/xrdp/startwm.sh && \
    chmod +x /etc/xrdp/startwm.sh

RUN adduser xrdp ssl-cert

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
