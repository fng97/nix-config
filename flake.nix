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
    in {
      # FIXME: make home-manager use NixOS configurations
      # # For quickly applying local settings with:
      # # home-manager switch --flake .#tempest
      # homeConfigurations = {
      #   tempest =
      #     nixosConfigurations.tempest.config.home-manager.users.${globals.user}.home;
      #   lookingglass =
      #     darwinConfigurations.lookingglass.config.home-manager.users."Noah.Masur".home;
      # };
      homeConfigurations."wsl" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home.nix ./wsl.nix ];
      };
      homeConfigurations."macbook" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-darwin";
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home.nix ./macbook.nix ];
      };

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
    };
}
