FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386

# دابەزاندنی پرۆگرامە ڕەسەنەکان لەگەڵ Picom بۆ دروستکردنی شێوازی Glass
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

# دروستکردنی یوزەری Ameer لەگەڵ دەسەڵاتی Sudo
RUN useradd -m -s /bin/bash Ameer && \
    echo "Ameer:123456" | chpasswd && \
    usermod -aG sudo Ameer

# دروستکردنی فۆڵدەرەکانی ڕێکخستن
RUN mkdir -p /home/Ameer/.config/picom /home/Ameer/.config/gtk-3.0 && \
    chown -R Ameer:Ameer /home/Ameer/.config

# رێکخستنی Picom بۆ دروستکردنی کاریگەری Glass (شووشەیی و شۆفبوون)
RUN echo 'backend = "glx";\n\
vsync = true;\n\
active-opacity = 0.90;\n\
inactive-opacity = 0.82;\n\
frame-opacity = 0.80;\n\
blur-background = true;\n\
blur-method = "dual_kawase";\n\
blur-strength = 7;' > /home/Ameer/.config/picom/picom.conf

# دروستکردنی CSS برای لایەوتی Glass لەسەر تێمی ڕەسەن
RUN echo 'panel.gtk-gradient, .xfce4-panel {\n\
    background-color: rgba(30, 30, 30, 0.55);\n\
    border-radius: 10px;\n\
}\n\
window {\n\
    background-color: rgba(25, 25, 25, 0.85);\n\
}' > /home/Ameer/.config/gtk-3.0/gtk.css

RUN chown -R Ameer:Ameer /home/Ameer/.config

# دیاریکردنی ڕاژەی گرافیکی (چالاککردنی Picom لەگەڵ XFCE)
RUN echo "picom -b --config ~/.config/picom/picom.conf &" > /home/Ameer/.xsession && \
    echo "exec dbus-launch --exit-with-session startxfce4" >> /home/Ameer/.xsession && \
    chown Ameer:Ameer /home/Ameer/.xsession && \
    chmod 755 /home/Ameer/.xsession

RUN sed -i 's/^allowed_users=.*/allowed_users=anybody/' /etc/X11/Xwrapper.config || echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config

# ڕێکخستنی xRDP
RUN sed -i 's/crypt_level=high/crypt_level=low/' /etc/xrdp/xrdp.ini && \
    sed -i 's/security_layer=negotiate/security_layer=rdp/' /etc/xrdp/xrdp.ini && \
    echo "#!/bin/sh" > /etc/xrdp/startwm.sh && \
    echo "unset DBUS_SESSION_BUS_ADDRESS" >> /etc/xrdp/startwm.sh && \
    echo "unset XDG_RUNTIME_DIR" >> /etc/xrdp/startwm.sh && \
    echo "picom -b --config /home/Ameer/.config/picom/picom.conf &" >> /etc/xrdp/startwm.sh && \
    echo "exec dbus-launch --exit-with-session startxfce4" >> /etc/xrdp/startwm.sh && \
    chmod +x /etc/xrdp/startwm.sh

RUN adduser xrdp ssl-cert

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
