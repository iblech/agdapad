{ config, pkgs, ... }:

let
  agdapad-package = pkgs.callPackage ./package.nix {};
  agdapad-static  = pkgs.callPackage ./static.nix {};
  mytigervnc = pkgs.tigervnc.override {
    fontDirectories = with pkgs; [ xorg.fontadobe75dpi xorg.fontmiscmisc xorg.fontcursormisc ];
  };
  myttyd = (pkgs.callPackage ./ttyd/default.nix {}).overrideAttrs (oldAttrs: rec {
    postPatch = ''
      sed -ie "/window.addEventListener('beforeunload', this.onWindowUnload);/ d" html/src/components/terminal/index.tsx
      sed -ie "s/document.title = data + ' | ' + this.title;/document.title = data;/" html/src/components/terminal/index.tsx
   '';
  });
  mydwm = pkgs.dwm.overrideAttrs (oldAttrs: rec {
    postPatch = ''
      sed -i -e 's/showbar\s*=\s*1/showbar = 0/' config.def.h
    '';
  });
  myemacs = pkgs.emacsWithPackages (epkgs: [ epkgs.evil epkgs.tramp-theme epkgs.ahungry-theme ]);
  myemacs-nox = pkgs.emacs-nox.pkgs.withPackages (epkgs: [ epkgs.evil epkgs.tramp-theme epkgs.ahungry-theme ]);
  myagda = pkgs.agda.withPackages (p: [ p.standard-library p.cubical p.agda-categories ]);
in {
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=20M
  '';

  time.hardwareClockInLocalTime = true;
  networking.firewall.enable = false;

  # This option defaults to true, but not if the system is itself a container.
  # We need to ensure that this option is set in any case, so that our nested
  # containers will work.
  boot.enableContainers = true;

  # This declaration is redundant if this configuration file is imported as a
  # container from the configuration file of a host system, of if it used for a
  # command such as `nixos-generate -f lxc`. However, for convenience, we also want
  # `nix-build "<nixpkgs/nixos>" -A system -I nixos-config=./container.nix` to work.
  # Without this option, nix-build would rightfully complain about missing file
  # system information.
  boot.isContainer = true;

  # When creating an lxc image using a command like `nixos-generate -c container.nix -f lxc`,
  # the file nixos/virtualisation/lxc-container.nix is included, thereby
  # enabling this option. We require it to be false, though.
  environment.noXlibs = false;

  systemd.services.xprovisor = {
    description = "xprovisor";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.websocat}/bin/websocat -e -E --binary ws-l:0.0.0.0:6080 sh-c:${agdapad-package}/xprovisor.pl";
    };
    path = with pkgs; [ bash perl coreutils utillinux xprintidle-ng xdotool netcat ];
  };

  systemd.services.xprovisor-maint = {
    description = "xmaint";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${agdapad-package}/xprovisor.pl";
      Environment = "WEBSOCAT_URI=/?maintainance";
    };
    path = with pkgs; [ bash perl coreutils utillinux xprintidle-ng xdotool netcat ];
  };

  systemd.timers.xprovisor-maint = {
    wantedBy = [ "timers.target" ];
    description = "xmaint";
    timerConfig = { OnCalendar = "*:0/1"; };
  };

  systemd.services.ttyprovisor = {
    description = "ttyprovisor";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      MemoryMax = "3G";
      ExecStart = "${myttyd}/bin/ttyd -b /__tty -a ${agdapad-package}/ttyprovisor.pl";
    };
    path = with pkgs; [ bash perl systemd utillinux coreutils shadow.su tmux myemacs-nox ];
  };

  systemd.services.ttyprovisor-maint = {
    description = "ttymaint";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${agdapad-package}/ttyprovisor.pl .maintainance";
    };
    path = with pkgs; [ bash perl systemd utillinux coreutils shadow.su tmux myemacs-nox ];
  };

  systemd.timers.ttyprovisor-maint = {
    wantedBy = [ "timers.target" ];
    description = "ttymaint";
    timerConfig = { OnCalendar = "*:0/1"; };
  };

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;

    # important to prevent annoying reconnects
    appendHttpConfig = ''
      proxy_send_timeout 600;
      proxy_read_timeout 600;
      proxy_http_version 1.1;
    '';

    virtualHosts.localhost = {
      locations = {
        "/" = {
           root = agdapad-static;
           extraConfig = "expires 1d;";
         };
	"/__tty" = {
	  proxyPass = "http://localhost:7681";
	  proxyWebsockets = true;
	};
	"/__vnc" = {
	  proxyPass = "http://localhost:6080";
	  proxyWebsockets = true;
	};
      };
    };
  };

  containers.xskeleton = {
    config =
      { config, pkgs, ... }:
      {
        services.journald.extraConfig = ''
          Storage=volatile
          RuntimeMaxUse=1M
        '';

        time.hardwareClockInLocalTime = true;

        networking.hostName = "ada";
        networking.firewall.enable = false;

        hardware.pulseaudio.enable = true;

        environment.systemPackages = with pkgs; [
          mytigervnc myemacs myagda screenkey st mydwm netcat
        ];

        fonts.fontconfig.enable = true;
        fonts.fonts = with pkgs; [ hack-font ubuntu_font_family ];

        programs.bash.enableCompletion = false;

        users.users.guest = { isNormalUser = true; description = "Guest"; home = "/home/guest"; uid = 10000; };

        services.xserver = {
          enable = true;
          # desktopManager.xfce.enable = true;
          displayManager.startx.enable = true;
        };

        systemd.services.vnc = {
          wantedBy = [ "multi-user.target" ];
          description = "vnc";
          serviceConfig = {
            User = "guest";
            ExecStart = "${agdapad-package}/vncinit.sh";
          };
          postStop = "${agdapad-package}/vncdown.sh";
          path = with pkgs; [ bash util-linux xorg.xauth mytigervnc netcat coreutils mydwm myemacs ];
        };

        systemd.paths.poweroff = {
          wantedBy = [ "multi-user.target" ];
          description = "poweroff after VNC logout";
          pathConfig = { PathExists = "/tmp/poweroff"; };
        };

        systemd.services.poweroff = {
          description = "poweroff after VNC logout";
          serviceConfig = { ExecStart = "${pkgs.systemd}/bin/poweroff"; };
        };
      };
    ephemeral = true;
    privateNetwork = true;
    bindMounts = { "/home/guest" = { hostPath = "/home/.skeleton"; isReadOnly = false; }; };
  };

  containers.ttyskeleton = {
    config =
      { config, pkgs, ... }:
      {
        services.journald.extraConfig = ''
          Storage=volatile
          RuntimeMaxUse=1M
        '';

        time.hardwareClockInLocalTime = true;

        networking.hostName = "ada";
        networking.firewall.enable = false;

        environment.systemPackages = with pkgs; [
          bash perl tmux vim myemacs-nox myagda
        ];

        programs.bash.enableCompletion = false;

        users.users.guest = { isNormalUser = true; description = "Guest"; home = "/home/guest"; uid = 10000; };
      };
    ephemeral = true;
    privateNetwork = true;
    bindMounts = { "/home/guest" = { hostPath = "/home/.skeleton"; isReadOnly = false; }; };
  };
}
