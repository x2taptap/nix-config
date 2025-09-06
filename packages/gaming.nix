{ pkgs }:

with pkgs; [
  mangohud
  lutris
  protonup
  lsfg-vk
  prismlauncher
  rpcs3
  oversteer
  protontricks
  linuxKernel.packages.linux_zen.xpadneo
  wineWowPackages.stable
  (steam.override {
    extraLibraries = pkgs: [ pkgs.fontconfig pkgs.nss pkgs.glfw];
  }).run
]
