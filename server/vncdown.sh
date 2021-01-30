#!${pkgs.bash}/bin/bash

${myTigervnc}/bin/vncserver -kill :1
touch /tmp/poweroff
