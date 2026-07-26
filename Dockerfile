FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386

# دابەزاندنی ئامرازەکان + picom (بۆ دیزاینی شەفافی و بلور)
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
    picom \
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
    arc-theme \
    papirus-icon-theme \
    fonts-inter \
    fonts-noto-color-emoji \
    fonts-roboto && \
    apt clean && rm -rf /var/lib/apt/lists/*

# دروستکردنی یوزەری Ameer
RUN useradd -m -s /bin/bash Ameer && \
    echo "Ameer:123456" | chpasswd && \
    usermod -aG sudo Ameer

# دابەزاندنی ئایکۆنەکانی Tela Circle
RUN git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git /tmp/tela-icons && \
    /tmp/tela-icons/install.sh -c dark && \
    rm -rf /tmp/tela-icons

# دروستکردنی فۆڵدەرەکانی ڕێکخستن بۆ Ameer
RUN mkdir -p /home/Ameer/.config/picom /home/Ameer/.config/xfce4/xfconf/xfce-perchannel-xml /home/Ameer/.config/autostart && \
    chown -R Ameer:Ameer /home/Ameer/.config

# ۱. دروستکردنی ڕێکخستنی Picom بۆ بەخشینی شووشەیی (Blur & Transparency)
RUN echo 'backend = "glx";\n\
vsync = true;\n\
active-opacity = 0.88;\n\
inactive-opacity = 0.78;\n\
frame-opacity = 0.85;\n\
corner-radius = 12;\n\
\n\
blur: {\n\
  method = "dual_kawase";\n\
  strength = 8;\n\
  background = true;\n\
  background-frame = true;\n\
  background-fixed = true;\n\
};\n\
\n\
opacity-rule = [\n\
  "90:class_g = \x27Xfce4-terminal\x27",\n\
  "85:class_g = \x27Xfce4-panel\x27"\n\
];' > /home/Ameer/.config/picom/picom.conf && \
    chown Ameer:Ameer /home/Ameer/.config/picom/picom.conf

# ۲. چالاککردنی auto-start بۆ Picom کاتێک دێسکتاپ دەکەوێتە کار
RUN echo '[Desktop Entry]\n\
Type=Application\n\
Name=Picom\n\
Exec=picom -b --config /home/Ameer/.config/picom/picom.conf\n\
Hidden=false\n\
NoDisplay=false\n\
X-GNOME-Autostart-enabled=true' > /home/Ameer/.config/autostart/picom.desktop && \
    chown Ameer:Ameer /home/Ameer/.config/autostart/picom.desktop

# ۳. ڕێکخستنی تێمەکە بۆ هەبوونی هەست و سێبەری Glassmorphism
RUN echo '<?xml version="1.0" encoding="UTF-8"?>\n\
<channel name="xsettings" version="1.0">\n\
  <property name="Net" type="empty">\n\
    <property name="ThemeName" type="string" value="Arc-Dark"/>\n\
    <property name="IconThemeName" type="string" value="Tela-circle-dark"/>\n\
  </property>\n\
  <property name="Gtk" type="empty">\n\
    <property name="FontName" type="string" value="Inter 10"/>\n\
  </property>\n\
</channel>' > /home/Ameer/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml && \
    chown Ameer:Ameer /home/Ameer/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml

# دیاریکردنی شاشەی دەستپێک
RUN echo "dbus-launch --exit-with-session startxfce4" > /home/Ameer/.xsession && \
    chown Ameer:Ameer /home/Ameer/.xsession && \
    chmod 755 /home/Ameer/.xsession

RUN sed -i 's/^allowed_users=.*/allowed_users=anybody/' /etc/X11/Xwrapper.config || echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config

# ڕێکخستنی xRDP
RUN sed -i 's/crypt_level=high/crypt_level=low/' /etc/xrdp/xrdp.ini && \
    sed -i 's/security_layer=negotiate/security_layer=rdp/' /etc/xrdp/xrdp.ini && \
    echo "#!/bin/sh" > /etc/xrdp/startwm.sh && \
    echo "unset DBUS_SESSION_BUS_ADDRESS" >> /etc/xrdp/startwm.sh && \
    echo "unset XDG_RUNTIME_DIR" >> /etc/xrdp/startwm.sh && \
    echo "exec dbus-launch --exit-with-session startxfce4" >> /etc/xrdp/startwm.sh && \
    chmod +x /etc/xrdp/startwm.sh

RUN adduser xrdp ssl-cert

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
