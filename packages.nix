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
  distrobox
  lsfg-vk
  prismlauncher
  vlc
  rpcs3
  uxplay
  unzip
  gnumake
  pods
  gcc
  gamescope
  protontricks
  blender
  linuxKernel.packages.linux_zen.xpadneo
  wineWowPackages.stable
  (steam.override {
    extraLibraries = pkgs: [ pkgs.fontconfig pkgs.nss ];
  }).run
]
