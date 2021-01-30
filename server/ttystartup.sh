#!${pkgs.bash}/bin/bash

set -e

cd /home/guest
. /etc/profile

mkdir -p .agda
echo "standard-library" > .agda/defaults
echo "cubical" >> .agda/defaults
echo "agda-categories" >> .agda/defaults
cat ${emacsrc} > .emacs

echo -en "\033]0;$1 | Agdapad\007"
exec ${pkgs.tmux}/bin/tmux new-session -A -s fun -- ${myemacs-nox}/bin/emacs hello.agda
