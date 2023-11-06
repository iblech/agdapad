# To create the ISO image:
# nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=iso.nix

{ config, lib, pkgs, ... }:

let
  agdapad-package = pkgs.callPackage ./package.nix {};
  slimAgda = pkgs.callPackage ./slim-agda.nix {};
  myemacs = pkgs.emacsWithPackages (epkgs: [ epkgs.evil epkgs.tramp-theme epkgs.ahungry-theme epkgs.polymode epkgs.markdown-mode epkgs.color-theme-sanityinc-tomorrow ]);
  mydwm = pkgs.dwm.overrideAttrs (oldAttrs: rec {
    postPatch = ''
      sed -i -e 's/showbar\s*=\s*1/showbar = 0/' config.def.h
    '';
  });
in {
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-base.nix>
  ];

  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=1M
  '';
  boot.kernel.sysctl = { "vm.dirty_writeback_centisecs" = 6000; };
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.timeout = lib.mkForce 2;
  boot.supportedFilesystems = lib.mkForce [];

  services.logrotate.enable = false;

  isoImage.appendToMenuLabel = " Live System";

  documentation.enable = false;
  documentation.doc.enable = false;

  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];

  networking = {
    hostName = "lovelace";
    firewall.enable = false;
    networkmanager.enable = false;
    networkmanager.wifi.powersave = true;
    wireless.enable = false;
  };

  fonts.fontconfig.enable = lib.mkForce true;

  programs.bash.enableCompletion = false;

  environment.systemPackages = with pkgs; [
    bash vim sshfs git screen socat mydwm
    (myemacs)
    (slimAgda)
  ];

  boot.postBootCommands = ''
    cd /root
    cp --no-preserve=mode -nrT ${agdapad-package}/skeleton-home .
    mkdir -p /root/.config/autostart
    ln -s ${agdapad-package}/emacs-agda.desktop /home/root/.config/autostart/
  '';

  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    libinput = {
      enable = true;
      touchpad.middleEmulation = true;
    };
  };

  systemd.services.agda = {
    after = [ "graphical.target" ];
    wantedBy = [ "graphical.target" ];
    description = "agda";
    script = ''
      cookie=$(mcookie)
      xauth -f /root/.Xauthority source - <<EOF
      add lovelace:1 . $cookie
      add lovelace/unix:1 . $cookie
      EOF
      # logic lifted from sx
      trap 'DISPLAY=:1 exec ${agdapad-package}/xstartup.sh & wait "$!"' USR1
      (trap "" USR1 && exec X :1 -noreset -auth /root/.Xauthority) & pid=$!
      wait "$pid"
    '';
    serviceConfig = {
      User = "root";
      TTYPath = "/dev/tty7";
      UtmpIdentifier = "tty7";
      UtmpMode = "user";
      StandardOutput = "journal";
      ExecStartPre = "${pkgs.kbd}/bin/chvt 7";
    };
    path = with pkgs; [ bash util-linux xorg.xauth xorg.xorgserver coreutils mydwm myemacs xterm ];
  };

  hardware.opengl.enable = false;
}
