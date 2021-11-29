#!/usr/bin/env bash

# We don't use TigerVNC's `vncserver` script, as (beginning at least with
# 1.11.0) it requires modern (but for our purposes too complex) session
# infrastructure. Rolling our own `vncserver` replacement is not too hard:

cookie=$(mcookie)
xauth -f /home/guest/.Xauthority source - <<EOF
add ada:1 . $cookie
add ada/unix:1 . $cookie
EOF

Xvnc :1 -auth /home/guest/.Xauthority -desktop ada:1 -geometry 1280x768 -SecurityTypes none -UseBlacklist=off -AlwaysShared &

until nc -z localhost 5901; do
  sleep 0.1
done

export AGDAPAD_SESSION_NAME="$(grep -z ^AGDAPAD_SESSION_NAME= /proc/1/environ | cut -d= -f2-)"

DISPLAY=:1 exec @out@/xstartup.sh
