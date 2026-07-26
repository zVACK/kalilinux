FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

# چالاککردنی معماریی 32-bit و زیاکردنی contrib/non-free
RUN dpkg --add-architecture i386 && \
    sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list.d/debian.sources || \
    sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list

# دابەزاندنی تەواوی فۆنتەکانی کوردی، عەرەبی، ئیمۆجی و ئامرازەکان
RUN apt update && apt install -y \
    locales \
    locales-all \
    fonts-noto \
    fonts-noto-core \
    fonts-noto-color-emoji \
    fonts-kacst \
    fonts-sil-scheherazade \
    fonts-freefarsi \
    fonts-arabeyes \
    fontconfig \
    ibus \
    ibus-m17n \
    m17n-db \
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
    neofetch \
    net-tools \
    iputils-ping \
    dnsutils \
    nmap \
    tcpdump \
    openvpn \
    pkexec \
    pulseaudio \
    pulseaudio-utils \
    pavucontrol \
    wine \
    wine32 \
    wine64 \
    winetricks \
    firefox-esr \
    chromium \
    vlc \
    obs-studio \
    audacity \
    gimp \
    inkscape \
    libreoffice \
    evince \
    filezilla \
    telegram-desktop \
    thunderbird \
    unzip \
    zip \
    p7zip-full \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    default-jdk \
    golang \
    cargo && \
    apt clean && rm -rf /var/lib/apt/lists/*

# ڕێکخستنی UTF-8 Locale بۆ پشتیوانی زمانی کوردی و ئیمۆجی
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# دروستکردنی یوزەری Ameer
RUN useradd -m -s /bin/bash Ameer && \
    echo "Ameer:123456" | chpasswd && \
    usermod -aG sudo Ameer

# دروستکردنی فۆڵدەری ڕێکخستنەکان
RUN mkdir -p /home/Ameer/.config/gtk-3.0 /home/Ameer/.config/fontconfig /home/Ameer/.config/xfce4/xfconf/xfce-perchannel-xml

# ڕێکخستنی فۆنتی ئیمۆجی (Fontconfig) تا ئیمۆجییە ڕەنگاوڕەنگەکان بەبێ کراش دەربکەون
RUN echo '<?xml version="1.0"?>\n\
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">\n\
<fontconfig>\n\
  <alias>\n\
    <family>sans-serif</family>\n\
    <prefer>\n\
      <family>Noto Sans</family>\n\
      <family>Noto Color Emoji</family>\n\
    </prefer>\n\
  </alias>\n\
  <alias>\n\
    <family>serif</family>\n\
    <prefer>\n\
      <family>Noto Serif</family>\n\
      <family>Noto Color Emoji</family>\n\
    </prefer>\n\
  </alias>\n\
  <alias>\n\
    <family>monospace</family>\n\
    <prefer>\n\
      <family>Noto Sans Mono</family>\n\
      <family>Noto Color Emoji</family>\n\
    </prefer>\n\
  </alias>\n\
</fontconfig>' > /home/Ameer/.config/fontconfig/fonts.conf

# چالاککردنی Dark Mode
RUN echo '<?xml version="1.0" encoding="UTF-8"?>\n\
<channel name="xsettings" version="1.0">\n\
  <property name="Net" type="empty">\n\
    <property name="ThemeName" type="string" value="Adwaita-dark"/>\n\
  </property>\n\
</channel>' > /home/Ameer/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml

# دانانی Glass Effect
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

# ڕێکخستنی xRDP
RUN sed -i 's/crypt_level=high/crypt_level=low/' /etc/xrdp/xrdp.ini && \
    sed -i 's/security_layer=negotiate/security_layer=rdp/' /etc/xrdp/xrdp.ini && \
    echo "export LANG=en_US.UTF-8" > /etc/xrdp/startwm.sh && \
    echo "export LC_ALL=en_US.UTF-8" >> /etc/xrdp/startwm.sh && \
    echo "exec startxfce4" >> /etc/xrdp/startwm.sh && chmod +x /etc/xrdp/startwm.sh

RUN echo "export LANG=en_US.UTF-8" > /home/Ameer/.xsession && \
    echo "export LC_ALL=en_US.UTF-8" >> /home/Ameer/.xsession && \
    echo "exec startxfce4" >> /home/Ameer/.xsession && \
    chown Ameer:Ameer /home/Ameer/.xsession && chmod 755 /home/Ameer/.xsession

RUN mkdir -p /var/run/dbus && dbus-uuidgen > /var/lib/dbus/machine-id

RUN adduser xrdp ssl-cert

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 3389

CMD ["/start.sh"]
