{
  description = "Yuri Flake";

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

    packages = import ./packages.nix { inherit pkgs; };
  in {
    nixosConfigurations = {
      yuri = lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          {
            nixpkgs.config.allowUnfree = true;
            environment.systemPackages = packages;
          }
        ];
      };
    };
  };
}
