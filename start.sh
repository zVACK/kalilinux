#!/bin/bash

# Start DBus service
service dbus start

# Prepare X11 socket folder
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

# Start PulseAudio in system mode safely
pulseaudio --start --system --disallow-exit --disable-shm --exit-idle-time=-1

# Start xRDP service
service xrdp start
service xrdp-sesman start

# Keep container running by tailing log files
touch /var/log/xrdp-sesman.log /var/log/xrdp.log
tail -f /var/log/xrdp*.log
