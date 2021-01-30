services.journald.extraConfig = ''
  Storage=volatile
  RuntimeMaxUse=20M
'';

time.timeZone = "Europe/Berlin";
time.hardwareClockInLocalTime = true;
networking.firewall.enable = false;

boot.enableContainers = true;

systemd.services.xprovisor = {
  description = "xprovisor";
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    ExecStart = "${pkgs.websocat}/bin/websocat -e -E --binary ws-l:192.168.0.2:6080 sh-c:${xprovisor}";
  };
  path = [ pkgs.bash ];
};

systemd.services.xprovisor-maint = {
  description = "xmaint";
  serviceConfig = {
    Type = "oneshot";
    ExecStart = "${xprovisor}";
    Environment = "WEBSOCAT_URI=/?maintainance";
  };
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
    ExecStart = "${myttyd}/bin/ttyd -a ${ttyprovisor}";
  };
};

systemd.services.ttyprovisor-maint = {
  description = "ttymaint";
  serviceConfig = {
    Type = "oneshot";
    ExecStart = "${ttyprovisor} .maintainance";
  };
};

systemd.timers.ttyprovisor-maint = {
  wantedBy = [ "timers.target" ];
  description = "ttymaint";
  timerConfig = { OnCalendar = "*:0/1"; };
};

services.openssh.enable = true;
services.openssh.permitRootLogin = "yes";

containers.skeleton = {
  config =
    { config, pkgs, ... }:
    {
      services.journald.extraConfig = ''
        Storage=volatile
        RuntimeMaxUse=1M
      '';

      time.timeZone = "Europe/Berlin";
      time.hardwareClockInLocalTime = true;

      networking.hostName = "ada";
      networking.firewall.enable = false;

      hardware.pulseaudio.enable = true;

      environment.systemPackages = with pkgs; [
        bash bastet bc chromium djview evince feh firefoxWrapper gimp
        git gnome3.gedit gnuplot golly gtypist imagemagick inkscape
        libreoffice moon-buggy mupdf zathura nano manpages
        redshift screen socat sshfs texmaker texstudio
        (texlive.combine {
          inherit (texlive) scheme-medium biblatex logreq xstring csquotes tabto-ltx
          soul xypic libertine chngcntr multirow bussproofs breakurl mweights
          fontaxes environ framed trimspaces adjustbox collectbox tikz-cd comment
          moderncv fontawesome ifsym a4wide cleveref arev shadethm blindtext
          todonotes mdframed bbding titlesec wrapfig makecell enumitem nopageno
          needspace stix subfigure footmisc lkproof ocgx2 media9 ucs
          dirtytalk tcolorbox tikzpagenodes ifoddpage fdsymbol kurier preview cjk
          dashrule ifmtarg eepic multibib graphbox datatool xfor substr;
        })
        tig myTigervnc unzip vim wget xaos xcalib xdotool xorg.xauth xorg.xev
        xorg.xgamma xorg.xkill xorg.xmessage xorg.xmodmap xorg.xwd
        xorg.xwininfo xorg.libxcb xrandr-invert-colors xsel xvkbd
        (pkgs.python3.withPackages (self: [ self.pygame self.numpy self.matplotlib self.pygments self.pip ]))
        icewm
        atom gnome3.gedit geany
        myemacs myAgda wineFull
        mumble pavucontrol
        screenkey
        st
        mono gcc
        stellarium fish-fillets-ng freedroidrpg myfrozen-bubble krita
        gnujump pingus tuxpaint xbill jumpnbump
      ];

      fonts.fontconfig.enable = true;
      fonts.fonts = with pkgs; [ hack-font ubuntu_font_family ];

      environment.variables = { EDITOR = "nano"; };
      programs.bash.enableCompletion = false;

      users.users.guest = { isNormalUser = true; description = "Guest"; home = "/home/guest"; uid = 10000; };

      services.xserver = {
        enable = true;
        desktopManager.xfce.enable = true;
        displayManager.startx.enable = true;
      };

      systemd.services.vnc = {
        wantedBy = [ "multi-user.target" ];
        description = "vnc";
        serviceConfig = {
          User = "guest";
          ExecStart = "${vncinit}";
        };
        postStop = "${vncdown}";
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

      time.timeZone = "Europe/Berlin";
      time.hardwareClockInLocalTime = true;

      networking.hostName = "ada";
      networking.firewall.enable = false;

      hardware.pulseaudio.enable = true;

      environment.systemPackages = with pkgs; [
        bash
        git
        manpages
        screen
        tig unzip vim wget
        myemacs-nox myAgda
      ];

      environment.variables = { EDITOR = "nano"; };
      programs.bash.enableCompletion = false;

      users.users.guest = { isNormalUser = true; description = "Guest"; home = "/home/guest"; uid = 10000; };
    };
  ephemeral = true;
  privateNetwork = true;
  bindMounts = { "/home/guest" = { hostPath = "/home/.skeleton"; isReadOnly = false; }; };
};
