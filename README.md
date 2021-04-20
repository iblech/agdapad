# Agdapad

**Live demo at https://agdapad.quasicoherent.io/.**


## Features

* Graphical mode (using TigerVNC/NoVNC) and text mode (using ttyd)
* Hot spares for fresh sessions (with emacs already prestarted)
* Cold spares for already existing sessions (with X, but not emacs, already
  prestarted)
* Robust container acquisition – people accessing the same Agdapad URL
  will be connected to the same session even in case of bad timing
* Löb-like nested containers
* Building on awesome open source technology: GNU/Linux, Perl, NixOS, TigerVNC,
  NoVNC, systemd
* AGPLv3+ licensed


## Self-hosting the backend

Self-hosting the backend is easiest if you are running NixOS. This is not
strictly necessary though, instructions for self-hosting the backend on any flavor
of Linux will be forthcoming.


### Instructions for a quick non-permanent setup

1. Create and start the container:

       $ nixos-container create box --config-file ./container.nix
       $ nixos-container start box

2. Inside the container, create the directory `/home/.skeleton` so that the
   scripts know that everything has been correctly set up. Files put in that
   directory are copied into the home directory of newly-created sessions.

       $ machinectl shell box mkdir /home/.skeleton

3. That's it. Test that text-mode access works:

       $ xdg-open http://box:7681/__tty/?arg=CuriousSessionName

   Test that graphical access works:

       $ websocat -E --binary tcp-l:127.0.0.1:5901 ws://box:6080/__vnc/CuriousSessionName &
       $ vncviewer localhost:1

   There will also be a webserver running at `http://box/`. However, do not
   expect this to work -- browsers establish websocket connections only over TLS.


### Instructions for a permanent setup

1. Create a directory in which the homes of all Agdapad sessions will be
   stored, for instance `/agdapad-homes`.
2. Populate the directory `/agdapad-homes/.skeleton` as you wish, for instance
   put exercise files there which you want to be available in every
   session. This directory may also be empty, but it has to exist. If you want
   the (copies of) the skeleton files to be writable by the guest users, give
   them UID 10000.
3. Add this to your `/etc/nixos/configuration.nix`:

       users.users.guest = { isNormalUser = true; description = "Guest"; home = "/agdapad-homes"; uid = 10000; };
       containers.box = {
         config =
           { config, pkgs, ... }:
           { imports = [ /tmp-iblech/agdapad/backend/container.nix ]; };
         ephemeral = true;
         autoStart = true;
         privateNetwork = true;
         hostAddress = "192.168.0.1";
         localAddress = "192.168.0.2";
         bindMounts = { "/home" = { hostPath = "/agdapad-homes"; isReadOnly = false; }; };
       };
4. Switch to the new configuration.


## Reverse proxying for TLS support

Add something like this to the `http` block in your `nginx.conf` to redirect
traffic (including https trafic) to the host to the container.

    # important to prevent annoying reconnects
    proxy_send_timeout 600;
    proxy_read_timeout 600;

    proxy_http_version 1.1;

    server {
        listen 0.0.0.0:80;
        listen [::]:80;
        server_name agdapad.quasicoherent.io;
        location /.well-known/acme-challenge {
            root /var/lib/acme/acme-challenge;
            auth_basic off;
        }
        location / {
            return 301 https://$host$request_uri;
        }
    }

    server {
        listen 0.0.0.0:443 ssl http2;
        listen [::]:443 ssl http2;
        server_name agdapad.quasicoherent.io;
        location /.well-known/acme-challenge {
            root /var/lib/acme/acme-challenge;
            auth_basic off;
        }
        ssl_certificate /var/lib/acme/agdapad.quasicoherent.io/fullchain.pem;
        ssl_certificate_key /var/lib/acme/agdapad.quasicoherent.io/key.pem;
        ssl_trusted_certificate /var/lib/acme/agdapad.quasicoherent.io/chain.pem;
        location / {
            proxy_pass http://192.168.0.2;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
        }
    }

If you are running NixOS, these settings can be achieved by the following entry
to `/etc/nixos/configuration.nix`.

    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      appendHttpConfig = ''
         # important to prevent annoying reconnects
         proxy_send_timeout 600;
         proxy_read_timeout 600;
         proxy_http_version 1.1;
      '';
      virtualHosts."agdapad.quasicoherent.io" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://192.168.0.2";
          proxyWebsockets = true;
        };
      };
    };


# Pitfalls

* Browsers support websockets only over https. Hence for testing the frontend,
  you will have to set up a https reverse proxy.

* The scripts check for the presence of the directory `/home/.skeleton` (in the container)
  to gauge whether `/home` has been set up correctly.

* If you encounter weird problems, check that the permissions in
  `/home/.skeleton` are set correctly.

* Because of the nested containers, you may run into limitations regarding open
  filehandles. Lift these limitations by something like:

      boot.kernel.sysctl = {
        "fs.inotify.max_user_watches" = 163840;
        "fs.inotify.max_user_instances" = 2048;
        "fs.file-max" = 655360;
      };


# Notes

* We use our own build of ttyd because the version provided in nixpkgs doesn't
  compile the html bundle from source, instead using a prepackaged binary blob
  for convenience (pull request [awaiting review](https://github.com/NixOS/nixpkgs/pull/110978)).
  We want to patch the html a bit to better tailor it to our needs (disable the
  confirmation dialog when leaving the site and beautifying the title bar).


# To do

* bundle and minify JS
* upload and download buttons
* virtual keypad on mobile
* system image for offline work
* ssh access
* document viewonly mode
* document `/~foo/bar.agda` http access
