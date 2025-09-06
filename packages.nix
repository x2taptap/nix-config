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
  materialgram
  pamixer
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
  dunst
  qbittorrent
  rpcs3
  uxplay
  oversteer
  notesnook
  unzip
  hyprpaper
  gnumake
  pods
  gcc
  waybar
  protontricks
  blender
  linuxKernel.packages.linux_zen.xpadneo
  wineWowPackages.stable
  apple-cursor
  wl-clipboard # Command-line copy/paste utilities for Wayland
  (steam.override {
    extraLibraries = pkgs: [ pkgs.fontconfig pkgs.nss pkgs.glfw];
  }).run
]
