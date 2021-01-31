{ config, pkgs, ... }:

let
  agdapad-package = pkgs.callPackage ./package.nix {};
  myTigervnc = pkgs.callPackage ./tigervnc/default.nix {
    fontDirectories = with pkgs; [ xorg.fontadobe75dpi xorg.fontmiscmisc xorg.fontcursormisc ];
  };
  myemacs = pkgs.emacsWithPackages (epkgs: [ epkgs.evil epkgs.modus-vivendi-theme epkgs.modus-operandi-theme epkgs.tramp-theme epkgs.ahungry-theme ]);
  myemacs-nox = pkgs.emacs-nox.pkgs.withPackages (epkgs: [ epkgs.evil epkgs.modus-vivendi-theme epkgs.modus-operandi-theme epkgs.tramp-theme epkgs.ahungry-theme ]);
  myAgda = pkgs.agda.withPackages (p: [ p.standard-library p.cubical p.agda-categories ]);
in {
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=20M
  '';

  time.hardwareClockInLocalTime = true;
  networking.firewall.enable = false;

  boot.enableContainers = true;

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
      ExecStart = "${pkgs.ttyd}/bin/ttyd -a ${agdapad-package}/ttyprovisor.pl";
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
          myTigervnc myemacs myAgda screenkey st dwm netcat
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
          path = with pkgs; [ bash myTigervnc netcat coreutils dwm myemacs ];
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
          bash tmux vim myemacs-nox myAgda
        ];

        programs.bash.enableCompletion = false;

        users.users.guest = { isNormalUser = true; description = "Guest"; home = "/home/guest"; uid = 10000; };
      };
    ephemeral = true;
    privateNetwork = true;
    bindMounts = { "/home/guest" = { hostPath = "/home/.skeleton"; isReadOnly = false; }; };
  };
}
