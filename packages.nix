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
  hyprpaper
  gnumake
  pods
  gcc
  ghostty
  wofi
  pcmanfm
  gamescope
  protontricks
  blender
  linuxKernel.packages.linux_zen.xpadneo
  wineWowPackages.stable
  apple-cursor
  hyprshot
  hyprls
  (steam.override {
    extraLibraries = pkgs: [ pkgs.fontconfig pkgs.nss pkgs.glfw];
  }).run
]
