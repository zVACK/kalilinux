#!/bin/bash

# پاککردنەوەی تەواوی لاک فایلەکانی X11 تاوەکو هیچ کێشەیەکی Display 10 ڕوونەدات
rm -rf /tmp/.X* /tmp/.X11-unix
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

# دەستپێکردنی ڕاژەکان بە پێویستی
service dbus start
service xrdp start
service xrdp-sesman start

# هێشتنەوەی کانتێنەرەکە
touch /var/log/xrdp-sesman.log /var/log/xrdp.log
tail -f /var/log/xrdp*.log
