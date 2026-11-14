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

cp --reflink=auto --no-preserve=mode --update=none -rT @out@/skeleton-home .

while :; do
  numberOfClients=$(ps xua | grep "nc localhos[t]" | wc -l)
  if [ "$numberOfClients" -ge 2 ]; then
    echo "$numberOfClients"
  fi
  sleep 1
done | osd_cat -l 1 -d 1 -c purple -A right -p top &

export AGDAPAD_SESSION_NAME="$(ls -1 $HOME/.session-name)"
export CHEZSCHEMELIBDIRS=/home/guest/lib

export http_proxy=http://localhost:1080
export https_proxy=http://localhost:1080

socat TCP-LISTEN:1080,reuseaddr,fork UNIX-CONNECT:/torsock &

eval $(dbus-launch --exit-with-session --sh-syntax)
systemctl --user import-environment DISPLAY XAUTHORITY http_proxy https_proxy
dbus-update-activation-environment DISPLAY XAUTHORITY http_proxy https_proxy

[ -x .xstartup ] && . .xstartup

if [ "${AGDAPAD_SESSION_NAME:0:3}" = "mgs" ]; then
  # launch a full desktop environment
  #mkdir -p .local/share/racket/8.4/collects
  #[ -e lib ] || ln -s .local/share/racket/8.4/collects lib
  emacs -mm hello.agda &
  exec xfce4-session
else
  dwm &
  exec emacs --fullscreen hello.agda
fi
