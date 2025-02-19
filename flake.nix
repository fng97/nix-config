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
    let
      # pkgs is overridden in standalone home-manager (for macOS)
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
    in {
      nixosConfigurations."wsl" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.default
          {
            system.stateVersion = "24.05";
            nix.settings.experimental-features = [ "flakes nix-command" ];
            wsl.enable = true;
            wsl.defaultUser = "fng";
            wsl.startMenuLaunchers = true;
            users.defaultUserShell = pkgs.fish;
            users.users.fng.extraGroups = [ "docker" ];
            programs.fish.enable = true;
            programs.nix-ld.enable = true;
            virtualisation.docker.enable = true;
          }

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.fng = {
              imports =
                [ (import ./home.nix { inherit inputs pkgs; }) ./wsl.nix ];
            };
          }
        ];
      };

      # macOS
      homeConfigurations.fng = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."aarch64-darwin";
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home.nix ./macos.nix ];
      };
    };
}
