#!/bin/sh

# set vnc passworld
x11vnc -storepasswd $VNC_PW ~/.vnc/passwd

# start vncserver
vncserver :1 -localhost no -geometry=$VNC_GEOMETRY -depth=$VNC_DEPTH

# start noVNC
./usr/lib/noVNC/utils/novnc_proxy --vnc localhost:5901

tail -f /dev/null