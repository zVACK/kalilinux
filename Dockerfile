FROM kalilinux/kali-rolling:latest

ENV DEBIAN_FRONTEND=noninteractive

# چالاککردنی پشتگیری 32-bit بۆ بەرنامەکانی Wine
RUN dpkg --add-architecture i386

# دابەزاندنی XFCE، XRDP، Wine و پاکێجە سەرەکییەکان
RUN apt update && apt install -y --no-install-recommends \
    xrdp \
    xfce4 \
    xfce4-goodies \
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
    kali-desktop-xfce \
    kali-themes \
    kali-defaults && \
    apt clean && rm -rf /var/lib/apt/lists/*

# دابەزاندنی winetricks ڕاستەوخۆ لە سەرچاوەی فەرمییەوە بۆ ڕێگری لە کێشەی apt
RUN wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
    -O /usr/local/bin/winetricks && chmod +x /usr/local/bin/winetricks

# دروستکردنی یوزەری Ameer لەگەڵ وشەی نهێنی 1234 و بەخشینی مۆڵەتی sudo
RUN useradd -m -s /bin/bash Ameer && \
    echo "Ameer:1234" | chpasswd && \
    usermod -aG sudo Ameer

# چەسپاندنی ڕووکاری ئەسڵیی کالی (Kali-Dark)
RUN mkdir -p /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/ && \
    echo '<?xml version="1.0" encoding="UTF-8"?><channel name="xsettings" version="1.0"><property name="Net" type="empty"><property name="ThemeName" type="string" value="Kali-Dark"/><property name="IconThemeName" type="string" value="Flat-Remix-Blue-Dark"/></property></channel>' > /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml

# دیاریکردنی سێشنی XFCE
RUN echo "startxfce4" > /etc/skel/.xsession && chmod 700 /etc/skel/.xsession

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
