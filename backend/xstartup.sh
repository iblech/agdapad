#!/usr/bin/env bash

. /etc/profile
cd

if [ -e .wait ]; then
  echo "* Am cold spare; waiting for provisioning..." >&2
  tempdir=$(mktemp -d)
  cp .Xauthority .ICEauthority $tempdir/
  read < .wait
  echo "  Am being provisioned." >&2
  cd
  cp $tempdir/.* .
fi

cp --no-preserve=mode -nrT @out@/skeleton-home .

[ -x .xstartup ] && . .xstartup

dwm &
exec emacs --fullscreen hello.agda

# alternative: launch a full desktop environment
eval $(dbus-launch --exit-with-session --sh-syntax)
systemctl --user import-environment DISPLAY XAUTHORITY
dbus-update-activation-environment DISPLAY XAUTHORITY
exec xfce4-session
