# To create the ISO image:
# nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=iso.nix

{ config, lib, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  services.journald.extraConfig = "Storage=volatile";
  boot.kernel.sysctl = { "vm.dirty_writeback_centisecs" = 6000; };
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking = {
    hostName = "lovelace";
    firewall.enable = false;
    networkmanager.enable = true;
    networkmanager.wifi.powersave = true;
    wireless.enable = false;
  };

  fonts.fontconfig.enable = lib.mkForce true;

  environment.systemPackages = with pkgs; [
    bash vim evince firefoxWrapper sshfs git screen socat
    (emacsWithPackages (epkgs: [ epkgs.evil epkgs.tramp-theme epkgs.ahungry-theme ]))
    (agda.withPackages (p: [ p.standard-library p.cubical p.agda-categories ]))
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

  services.xserver = {
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
}