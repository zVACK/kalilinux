#!/bin/bash

# دروستکردنی فۆڵدەری X11 پێش دەستپێکردنی xrdp
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix
rm -rf /tmp/.X*-lock /tmp/.X11-unix/X*

# دەستپێکردنی ڕاژەکان
service dbus start
service xrdp start
service xrdp-sesman start

# هێشتنەوەی کانتێنەرەکە
touch /var/log/xrdp-sesman.log
tail -f /var/log/xrdp-sesman.log
