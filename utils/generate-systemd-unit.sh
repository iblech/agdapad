#!/usr/bin/env bash

set -e

hostip="$1"
containerip="$2"
home="$3"

if [ -z "$hostip" ] || [ -z "$containerip" ] || [ -z "$home" ]; then
  echo "usage: $0 hostip containerip /home/dir/for/the/container" >&2
  exit 1
fi

cd backend

[ -e container.nix ] || {
  echo "not found: ./container.nix" >&2
  exit 1
}

[ -d "$home/.skeleton" ] || {
  echo "not found: $home/.skeleton (should be a directory)" >&2
  exit 1
}

dir="$(mktemp -d)"

function cleanup {
    rm -rf -- "$dir"
}

trap cleanup EXIT

cat > $dir/configuration.nix <<EOF
{ config, pkgs, fetchurl, lib, ... }:
{
  boot.enableContainers = true;
  boot.isContainer = true;

  containers.agdapad = {
    config =
      { config, pkgs, ... }:
      { imports = [ $PWD/container.nix ];
      };
    ephemeral = true;
    autoStart = true;
    privateNetwork = true;
    hostAddress = "$hostip";
    localAddress = "$containerip";
    bindMounts = { "/home" = { hostPath = "$home"; isReadOnly = false; }; };
  };
}
EOF

system=$(nix-build "<nixpkgs/nixos>" -I nixos-config=$dir/configuration.nix -A system)

sed -e "s+/etc/containers/+$system/etc/containers/+" -e "s+%i+agdapad+g" < $system/etc/systemd/system/container@agdapad.service
