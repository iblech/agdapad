#!${pkgs.bash}/bin/bash

${myTigervnc}/bin/vncserver :1 -xstartup ${pkgs.coreutils}/bin/true -geometry 1280x768 -SecurityTypes none -UseBlacklist=off -AlwaysShared

until ${pkgs.netcat}/bin/nc -z localhost 5901; do
  ${pkgs.coreutils}/bin/sleep 0.1;
done

DISPLAY=:1 exec ${xstartup}
