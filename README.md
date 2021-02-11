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


## Instructions for a quick non-permanent setup

1. Create and start the container:

       $ nixos-container create box --config-file ./container.nix
       $ nixos-container start box

2. Inside the container, create the directory `/home/.skeleton` so that the
   scripts know that everything has been correctly set up. Files put in that
   directory are copied into the home directory of newly-created sessions.

       $ machinectl shell box mkdir /home/.skeleton

3. That's it. Test that text-mode access works:

       $ xdg-open http://box:7681/?arg=CuriousSessionName

   Test that graphical access works:

       $ websocat --binary tcp-l:127.0.0.1:5901 ws://box:6080/CuriousSessionName &
       $ vncviewer localhost:1


## Instructions for a permanent setup

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
           {config, pkgs, ...}:
           { imports = [ /tmp-iblech/agdapad/backend/container.nix ]; };
         ephemeral = true;
         autoStart = true;
         privateNetwork = true;
         hostAddress = "192.168.0.1";
         localAddress = "192.168.0.2";
         bindMounts = { "/home" = { hostPath = "/agdapad-homes"; isReadOnly = false; }; };
       };
4. Switch to the new configuration.


## Self-hosting the frontend

The frontend just consists of a couple of static files which can be hosted with
any webserver. The server name `agdapad.quasicoherent.io` is hardcoded a
couple of times; you will have to change these to reference your own server.

You will also need to set up a couple of rewrite rules so that your webserver
correctly reverse-proxies requests to the backend server ports. For Apache2,
the required configuration looks as follows.

    RewriteEngine on
    SSLProxyEngine on

    RewriteCond %{REQUEST_URI} !/__tty
    RewriteCond %{HTTP:Upgrade} websocket [NC]
    RewriteCond %{HTTP:Connection} upgrade [NC]
    RewriteRule .* "ws://localhost:6080%{REQUEST_URI}" [P,L,QSA]

    RewriteCond %{REQUEST_URI} /__tty
    RewriteCond %{HTTP:Upgrade} websocket [NC]
    RewriteCond %{HTTP:Connection} upgrade [NC]
    RewriteRule .* "ws://localhost:7681/ws" [P,L,QSA]
    ProxyPass /__tty http://localhost:7681/
    ProxyPassReverse /__tty http://localhost:7681/
    ProxyRequests off


# Pitfalls

* Browsers support websockets only over https. Hence for testing the frontend,
  you will have to set up a https reverse proxy.

* The scripts check for the presence of the directory `/home/.skeleton` (in the container)
  to gauge whether `/home` has been set up correctly.

* If you encounter weird problems, check that the permissions in
  `/home/.skeleton` are set correctly.

* Because of the nested containers, you may run into limitations regarding open
  filehandles. Left these limitations by something like `boot.kernel.sysctl = { "fs.file-max" = 65536; }`.


# Notes

* We currently use our own build of TigerVNC because the version provided in
  nixpkgs is broken as of writing (pull request is in the making).

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
