{ config, pkgs, ... }:

let
  agdapad-package = pkgs.callPackage ./package.nix {};
  agdapad-static  = pkgs.callPackage ./static.nix {};
  mydwm = pkgs.dwm.overrideAttrs (oldAttrs: rec {
    postPatch = ''
      sed -i -e 's/showbar\s*=\s*1/showbar = 0/' config.def.h
    '';
  });
  myemacs = pkgs.emacs.pkgs.withPackages (epkgs: [ epkgs.polymode epkgs.markdown-mode epkgs.evil epkgs.tramp-theme epkgs.ahungry-theme epkgs.color-theme-sanityinc-tomorrow epkgs.use-proxy ]);
  myemacs-nox = pkgs.emacs-nox.pkgs.withPackages (epkgs: [ epkgs.evil epkgs.tramp-theme epkgs.ahungry-theme epkgs.color-theme-sanityinc-tomorrow epkgs.use-proxy ]);
  padova2025 = pkgs.agdaPackages.mkDerivation {
    pname = "padova2025";
    version = "0.1";
    src = pkgs.fetchFromGitHub {
      owner = "iblech";
      repo = "lets-play-agda";
      rev = "bd627bff4abdcbdc653f704b39224ca9c38f8727";
      hash = "sha256-ztrKpqSFVh9p0Vremjcsg0Id6T8nBldJU9MP1yAxsO0=";
    };
    buildInputs = [ pkgs.agdaPackages.cubical ];
    meta = {};
  };
  myagda = pkgs.agda.withPackages (p: [ p.standard-library p.cubical p.agda-categories p._1lab p.generics p.functional-linear-algebra padova2025 ]);
in {
  services.journald.settings.Journal = {
    Storage = "volatile";
    RuntimeMaxUse = "20M";
  };

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

  systemd.services.xprovisor = {
    description = "xprovisor";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.websocat}/bin/websocat -e -E --binary --ping-interval 30 ws-l:0.0.0.0:6080 sh-c:${agdapad-package}/xprovisor.pl";
    };
    path = with pkgs; [ bash perl coreutils util-linux xprintidle-ng xdotool netcat gawk procps ];
  };

  systemd.services.xprovisor-maint = {
    description = "xmaint";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${agdapad-package}/xprovisor.pl";
      Environment = "AGDAPAD_ACTION=maintainance";
    };
    path = with pkgs; [ bash perl coreutils util-linux xprintidle-ng xdotool netcat gawk procps ];
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
      ExecStart = "${pkgs.ttyd}/bin/ttyd -W -b /__tty -a ${agdapad-package}/ttyprovisor.pl";
    };
    path = with pkgs; [ bash perl systemd util-linux coreutils shadow.su tmux myemacs-nox ];
  };

  systemd.services.ttyprovisor-maint = {
    description = "ttymaint";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${agdapad-package}/ttyprovisor.pl";
      Environment = "AGDAPAD_ACTION=maintainance";
    };
    path = with pkgs; [ bash perl systemd util-linux coreutils shadow.su tmux myemacs-nox ];
  };

  systemd.timers.ttyprovisor-maint = {
    wantedBy = [ "timers.target" ];
    description = "ttymaint";
    timerConfig = { OnCalendar = "*:0/1"; };
  };

  systemd.services.terminate-before-shutdown = {
    description = "terminate-before-shutdown";
    before = [ "shutdown.target" ];
    wantedBy = [ "shutdown.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${agdapad-package}/xprovisor.pl";
      Environment = "AGDAPAD_ACTION=terminate";
      TimeoutStartSec = "0";
    };
    path = with pkgs; [ bash perl coreutils util-linux xprintidle-ng xdotool netcat gawk procps ];
  };

  users.users.guest = { isNormalUser = true; description = "Guest"; home = "/home/guest"; uid = 10000; };

  systemd.services.nginx.serviceConfig.BindReadOnlyPaths = "/proc/loadavg:/loadavg";
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;

    user = "guest";
    # so nginx can serve /~foo/bar.agda

    package = pkgs.nginxMainline.override {
      modules = with pkgs.nginxModules; [ brotli develkit moreheaders zstd ];
    };

    # important to prevent annoying reconnects
    appendHttpConfig = ''
      proxy_send_timeout 600;
      proxy_read_timeout 600;
      proxy_http_version 1.1;
    '';

    commonHttpConfig = ''
      brotli on;
      brotli_static on;
      brotli_types application/json application/javascript application/xml application/xml+rss image/svg+xml text/css text/javascript text/plain text/xml text/x-agda text/x-scheme text/markdown;
      zstd on;
      zstd_types application/json application/javascript application/xml application/xml+rss image/svg+xml text/css text/javascript text/plain text/xml text/x-agda text/x-scheme text/markdown;
      types {
        text/x-agda   agda lagda;
        text/x-scheme scm rkt;
        text/x-asm    s;
      }
      charset utf-8;
      charset_types text/x-agda text/x-scheme text/x-asm text/markdown;
      map $request_method $agdapad_is_dav {
        GET     0;
        HEAD    0;
        default 1;
      }
    '';

    virtualHosts.localhost = {
      locations = {
        "/" = {
          root = agdapad-static;
          extraConfig = ''
            expires 7d;
          '';
        };
        "/index.html" = {
          root = agdapad-static;
          extraConfig = ''
            expires 3h;
#            set_by_lua_block $do_preconnect {
#              local f = io.open("/loadavg")
#              local line = f:read("*line")
#              f:close()
#              local l1 = string.match(line, "([%d]*%.[%d]*)%s")
#              if tonumber(l1) >= 2 then
#                return "0"
#              else
#                return "1"
#              end
#            }
#            sub_filter '"__DO_PRECONNECT__"' $do_preconnect;
          '';
        };
        "/__tty" = {
          proxyPass = "http://localhost:7681";
          proxyWebsockets = true;
        };
        "/__vnc" = {
          proxyPass = "http://localhost:6080";
          proxyWebsockets = true;
        };
        "~ ^/~(?<agdapad_session>\\w+)(?<agdapad_path>/.*)?$" = {  # exclude both ".."-style enumeration attacks and access to ".skeleton", ".hot-spare-*" etc.
          alias = "/web-home/$agdapad_session$agdapad_path";
          extraConfig = ''
            expires epoch;
            autoindex on;
            disable_symlinks on;
            # Apache computes ETags differently, don't want mismatches
            etag off;
            client_max_body_size 500m;
            error_page 418 = @dav;
            if ($agdapad_is_dav) {
              return 418;
            }
          '';
        };
        "@dav" = {
          proxyPass = "http://127.0.0.1:8080";
          extraConfig = ''
            client_max_body_size 500m;
            proxy_request_buffering off;
          '';
        };
      };
    };
  };

  # required so nginx can serve /~foo/bar.agda
  systemd.services.nginx.serviceConfig.ProtectHome = "no";

  # A view of /home for nginx and Apache in which symlinks are never followed,
  # to prevent cross-session interference.
  fileSystems."/web-home" = {
    device = "/home";
    fsType = "none";
    options = [ "bind" "nosymfollow" ];
  };

  # WebDAV access to /~foo using Apache. nginx's DAV support is too incomplete.
  services.httpd = {
    enable = true;
    user = "guest";
    group = "users";
    virtualHosts.dav = {
      listen = [ { ip = "127.0.0.1"; port = 8080; } ];
      extraConfig = ''
        RequestHeader edit Destination ^(https?://[^/]+)?/ http://127.0.0.1:8080/ early

        AliasMatch "^/~(\w+)(/.*)?$" "/web-home/$1$2"

        DavLockDB /run/httpd/DavLock
        DavMinTimeout 600

        # 500 MiB
        LimitRequestBody 524288000

        <Directory "/web-home">
          Dav On
          # in particular no FollowSymLinks
          Options None
          AllowOverride None
          Require all granted
          DirectorySlash Off
          DirectoryIndex disabled
        </Directory>

        # Limit actions on the home directory itself
        <LocationMatch "^/~\w+/?$">
          <Limit PUT DELETE MKCOL COPY MOVE>
            Require all denied
          </Limit>
        </LocationMatch>
      '';
    };
  };

  containers.xskeleton = {
    config =
      { config, pkgs, ... }:
      {
        system.stateVersion = "${config.system.nixos.release}";
        services.journald.settings.Journal = {
          Storage = "volatile";
          RuntimeMaxUse = "1M";
        };

        time.hardwareClockInLocalTime = true;

        networking.hostName = "ada";
        networking.firewall.enable = false;

        services.pulseaudio.enable = false;

        environment.systemPackages = with pkgs; [
          tigervnc myemacs myagda screenkey st mydwm netcat xosd killall
        ];

        fonts.fontconfig.enable = true;
        fonts.packages = with pkgs; [ hack-font ubuntu-classic ];

        programs.bash.completion.enable = false;

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
          path = with pkgs; [ bash util-linux xauth tigervnc netcat coreutils mydwm myemacs ];
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

        documentation.doc.enable = false;
        services.speechd.enable = false;
      };
    ephemeral = true;
    privateNetwork = true;
    bindMounts =
      # The reference to /home/.skeleton will be changed by xprovisor.pl
      # before actually instantiating the container
      { "/home/guest" = { hostPath = "/home/.skeleton"; isReadOnly = false; };
        "/torsock" = { hostPath = "/torsock"; isReadOnly = false; };
        "/home/guest/shared-files" = { hostPath = "/home/.shared-files"; isReadOnly = false; };
        "/home/guest/MGS2024" = { hostPath = "/home/MGS2024"; isReadOnly = true; };
        "/home/guest/Padova2024" = { hostPath = "/home/Padova2024"; isReadOnly = true; };
        #"/home/guest/Padova2025" = { hostPath = "/home/Padova2025"; isReadOnly = true; };
        "/home/guest/Verona2024" = { hostPath = "/home/Verona2024"; isReadOnly = true; };
      };
    extraFlags = [ "--setenv=AGDAPAD_SESSION_NAME=__SESSION_NAME__" ];
  };

  containers.ttyskeleton = {
    config =
      { config, pkgs, ... }:
      {
        system.stateVersion = "${config.system.nixos.release}";
        services.journald.settings.Journal = {
          Storage = "volatile";
          RuntimeMaxUse = "1M";
        };

        time.hardwareClockInLocalTime = true;

        networking.hostName = "ada";
        networking.firewall.enable = false;

        environment.systemPackages = with pkgs; [
          bash perl tmux vim myemacs-nox myagda
        ];

        programs.bash.completion.enable = false;

        users.users.guest = { isNormalUser = true; description = "Guest"; home = "/home/guest"; uid = 10000; };

        documentation.doc.enable = false;
        services.speechd.enable = false;
      };
    ephemeral = true;
    privateNetwork = true;
    # The reference to /home/.skeleton will be changed by ttyprovisor.pl
    # before actually instantiating the container
    bindMounts =
      { "/home/guest" = { hostPath = "/home/.skeleton"; isReadOnly = false; };
        "/home/guest/shared-files" = { hostPath = "/home/.shared-files"; isReadOnly = false; };
        "/home/guest/MGS2024" = { hostPath = "/home/MGS2024"; isReadOnly = true; };
        "/home/guest/Padova2024" = { hostPath = "/home/Padova2024"; isReadOnly = true; };
        "/home/guest/Verona2024" = { hostPath = "/home/Verona2024"; isReadOnly = true; };
      };
    extraFlags = [ "--setenv=AGDAPAD_SESSION_NAME=__SESSION_NAME__" ];
  };

  documentation.doc.enable = false;
}
