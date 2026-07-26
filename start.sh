#!/bin/bash

# Start DBus service
service dbus start

# Prepare X11 socket folder
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

# Start PipeWire PulseAudio service in background
pipewire-pulse &

# Keep container running continuously
exec tail -f /dev/null
