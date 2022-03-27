# To create the ISO image:
# nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=iso.nix

{ config, lib, pkgs, ... }:

let
  agdapad-package = pkgs.callPackage ./package.nix {};
  slimAgda = pkgs.callPackage ./slim-agda.nix {};
in {
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=1M
  '';
  boot.kernel.sysctl = { "vm.dirty_writeback_centisecs" = 6000; };
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.timeout = lib.mkForce 2;
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "ext4" "vfat" "ntfs" "cifs" ];

  isoImage.appendToMenuLabel = " Live System";

  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];

  networking = {
    hostName = "lovelace";
    firewall.enable = false;
    networkmanager.enable = true;
    networkmanager.wifi.powersave = true;
    wireless.enable = false;
  };

  fonts.fontconfig.enable = lib.mkForce true;

  environment.systemPackages = with pkgs; [
    bash vim firefoxWrapper sshfs git screen socat
    (emacsWithPackages (epkgs: [ epkgs.evil epkgs.tramp-theme epkgs.ahungry-theme ]))
    (slimAgda)
  ];

  fonts.fonts = with pkgs; [ ubuntu_font_family ];

  users.users.ada = {
    isNormalUser = true;
    description = "Ada Lovelace";
    createHome = true;
    home = "/home/ada";
    uid = 1000;
    initialHashedPassword = "$6$utLZPDNys$nxpqRBobo7NAi9kFs7J8Ar5UN2zJY97.tuavJyk1ACyVoELeUwS3AtU7eCPq.R3Yxtb3GvmpuOuH0xrww0pdp.";
  };

  boot.postBootCommands = ''
    cd /home/ada
    cp --no-preserve=mode -nrT ${agdapad-package}/skeleton-home .
    mkdir -p /home/ada/.config/autostart
    ln -s ${agdapad-package}/emacs-agda.desktop /home/ada/.config/autostart/
    chown -R ada.users .
  '';

  services.xserver = {
    #layout = "de";
    #xkbVariant = "nodeadkeys";
    enable = true;
    desktopManager.xfce.enable = true;
    displayManager = {
      lightdm.enable = true;
      autoLogin = {
        enable = true;
        user = "ada";
      };
    };
    libinput = {
      enable = true;
      touchpad.middleEmulation = true;
    };
  };

  hardware.opengl.enable = false;
}
