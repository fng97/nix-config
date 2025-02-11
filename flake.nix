{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim.url = "github:fng97/nixvim";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nixos-wsl, ... }@inputs:
    let pkgs = nixpkgs.legacyPackages."x86_64-linux";
    in rec {
      nixosConfigurations."wsl" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.default
          {
            system.stateVersion = "24.05";
            wsl.enable = true;
            wsl.defaultUser = "fng";
            programs.fish.enable = true;
            users.defaultUserShell = pkgs.fish;
            # wsl.startMenuLaunchers = true;
          }

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.fng = import ./home.nix { inherit inputs pkgs; };
          }
        ];
      };

      # For quickly applying local settings with:
      # home-manager switch --flake .#fng
      homeConfigurations = {
        fng = nixosConfigurations.wsl.config.home-manager.users.fng.home;
      };
    };
}
