{ pkgs }:

with pkgs; [
  vim
  wget
  git
  htop
  librewolf-bin
  pciutils
  gparted
  gnome-disk-utility
  gh
  unrar
  fastfetch
  vscode
  vesktop
  telegram-desktop
  easyeffects
  pavucontrol
  mangohud
  lutris
  cage
  lm_sensors
  protonup
  vmware-workstation
  distrobox
  lsfg-vk
  prismlauncher
  obs-studio
  vlc
  rpcs3
  uxplay
  gamescope
  linuxKernel.packages.linux_zen.xpadneo
  (steam.override {
    extraLibraries = pkgs: [ pkgs.fontconfig pkgs.nss ];
  }).run
]
