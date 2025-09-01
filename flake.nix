{
  description = "Yuri Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
  };

  outputs = { self, nixpkgs, chaotic, ... }:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;

    # Import nixpkgs with Chaotic Nyx overlay
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        chaotic.overlays.default
      ];
    };

    packages = import ./packages.nix { inherit pkgs; };
  in {
    nixosConfigurations = {
      yuri = lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          chaotic.nixosModules.default # Add Chaotic Nyx module
          {
            nixpkgs.config.allowUnfree = true;
            environment.systemPackages = packages;
          }
        ];
      };
    };
  };
}