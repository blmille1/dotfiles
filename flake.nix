{
  description = "Brandon's dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nix-darwin, sops-nix, ... }: let
    mkHome = system: modules:
      home-manager.lib.homeManagerConfiguration {
        # Instantiate nixpkgs here (not legacyPackages) so config applies.
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            # pipx's test suite is not relevant to its runtime here. Skip its
            # package checks so Home Manager can build the configured environment.
            (_: prev: {
              pipx = prev.pipx.overrideAttrs (_: {
                doCheck = false;
                doInstallCheck = false;
              });
            })
          ];
        };
        inherit modules;
      };
  in {
    # The output Home Manager looks for. The name is username@hostname
    homeConfigurations = {
      "blmille1@Millers-Air-M5" = mkHome "aarch64-darwin" [
        sops-nix.homeManagerModules.sops
        ./home/mac.nix
      ];
      # WSL
      "brandon@brenda-dell-wsl" = mkHome "x86_64-linux" [
        sops-nix.homeManagerModules.sops
        ./home/wsl.nix
      ];
      # Ubuntu Server
      "brandon@iris-server" = mkHome "x86_64-linux" [
        sops-nix.homeManagerModules.sops
        ./home/iris.nix
      ];
    };

    # System Settings
    darwinConfigurations."Millers-Air-M5" = nix-darwin.lib.darwinSystem {
      modules = [ ./darwin/configuration.nix ];
    };
  };
}
