#!/usr/bin/env bash

vncserver :1 -xstartup true -geometry 1280x768 -SecurityTypes none -UseBlacklist=off -AlwaysShared

until nc -z localhost 5901; do
  sleep 0.1
done

DISPLAY=:1 exec @out@/xstartup.sh
