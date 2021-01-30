#!${pkgs.bash}/bin/bash

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

mkdir -p .agda
echo "standard-library" > .agda/defaults
echo "cubical" >> .agda/defaults
echo "agda-categories" >> .agda/defaults
cat ${emacsrc} > .emacs

[ -x .xstartup ] && . .xstartup

${mydwm}/bin/dwm &
exec ${myemacs}/bin/emacs --fullscreen hello.agda

eval $(dbus-launch --exit-with-session --sh-syntax)
systemctl --user import-environment DISPLAY XAUTHORITY
dbus-update-activation-environment DISPLAY XAUTHORITY
exec xfce4-session
