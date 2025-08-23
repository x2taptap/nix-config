{
  description = "Nix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    yuri = {
      mojhost = lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          {
            nixpkgs.config.allowUnfree = true;

            environment.systemPackages = with pkgs; [
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
              (pkgs.steam.override {
                extraLibraries = pkgs: [ pkgs.fontconfig pkgs.nss ];
              }).run
            ];
          }
        ];
      };
    };
  };
}
