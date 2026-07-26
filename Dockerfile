FROM kalilinux/kali-rolling:latest

ENV DEBIAN_FRONTEND=noninteractive

# چالاککردنی پشتگیری 32-bit بۆ بەرنامەکانی Wine (.exe)
RUN dpkg --add-architecture i386

# بەرزکردنەوەی سیستەمەکە و دابەزاندنی XFCE و ڕووکاری فەرمیی Kali Linux
RUN apt update && apt full-upgrade -y && apt install -y \
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
    policykit-1 \
    pulseaudio \
    pulseaudio-utils \
    wine \
    wine32 \
    wine64 \
    winetricks \
    firefox-esr \
    kali-desktop-xfce \
    kali-themes \
    kali-defaults && \
    apt clean && rm -rf /var/lib/apt/lists/*

# دروستکردنی یوزەری Ameer لەگەڵ وشەی نهێنی 1234 و مۆڵەتی sudo
RUN useradd -m -s /bin/bash Ameer && \
    echo "Ameer:1234" | chpasswd && \
    usermod -aG sudo Ameer

# دیاریکردنی ڕووکاری فەرمیی Kali (Dark Theme) بۆ یوزەری Ameer
RUN mkdir -p /home/Ameer/.config/xfce4/xfconf/xfce-perchannel-xml/
RUN echo '<?xml version="1.0" encoding="UTF-8"?><channel name="xsettings" version="1.0"><property name="Net" type="empty"><property name="ThemeName" type="string" value="Kali-Dark"/><property name="IconThemeName" type="string" value="Flat-Remix-Blue-Dark"/></property></channel>' > /home/Ameer/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml

# دانانی سێشنی XFCE و ڕێکخستنی خاوەندارێتی بوخچەی home
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
