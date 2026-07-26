FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386

RUN apt update && apt install -y \
    xrdp \
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

# دروستکردنی یوزەری Ameer و دانانی پاسۆرد
RUN useradd -m -s /bin/bash Ameer && \
    echo "Ameer:123456" | chpasswd && \
    usermod -aG sudo Ameer

# دروستکردنی فۆڵدەری ڕێکخستنی GTK بۆ یوزەری Ameer
RUN mkdir -p /home/Ameer/.config/gtk-3.0 /home/Ameer/.config/xfce4/xfconf/xfce-perchannel-xml

# چالاککردنی Dark Mode بۆ XFCE بە شێوازی ڕەسەن
RUN echo '<?xml version="1.0" encoding="UTF-8"?>\n\
<channel name="xsettings" version="1.0">\n\
  <property name="Net" type="empty">\n\
    <property name="ThemeName" type="string" value="Adwaita-dark"/>\n\
  </property>\n\
</channel>' > /home/Ameer/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml

# دانانی شێوازی شووشەیی (Glass Effect) لە ڕێگەی CSSی ڕەسەنەوە
RUN echo 'panel.gtk-gradient, .xfce4-panel {\n\
    background-color: rgba(15, 15, 15, 0.45) !important;\n\
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);\n\
}\n\
.xfce4-panel button {\n\
    background-color: transparent !important;\n\
}\n\
window, dialog {\n\
    background-color: rgba(20, 20, 20, 0.85);\n\
}' > /home/Ameer/.config/gtk-3.0/gtk.css

RUN chown -R Ameer:Ameer /home/Ameer/.config

RUN sed -i 's/^allowed_users=.*/allowed_users=anybody/' /etc/X11/Xwrapper.config || echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config

# ڕێکخستنی xRDP ڕێک وەک سەرەتا بۆ ئەوەی بە هیچ شێوەیەک هەڵەی Session نەدات
RUN sed -i 's/crypt_level=high/crypt_level=low/' /etc/xrdp/xrdp.ini && \
    sed -i 's/security_layer=negotiate/security_layer=rdp/' /etc/xrdp/xrdp.ini && \
    echo "exec startxfce4" > /etc/xrdp/startwm.sh && chmod +x /etc/xrdp/startwm.sh

RUN echo "startxfce4" > /home/Ameer/.xsession && chown Ameer:Ameer /home/Ameer/.xsession && chmod 755 /home/Ameer/.xsession

# Generate machine-id for dbus
RUN mkdir -p /var/run/dbus && dbus-uuidgen > /var/lib/dbus/machine-id

RUN adduser xrdp ssl-cert

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
