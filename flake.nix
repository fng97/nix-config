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

  outputs = { nixpkgs, home-manager, nixos-wsl, ... }@inputs: {
    nixosConfigurations."wsl" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      modules = [
        nixos-wsl.nixosModules.default
        ({ config, pkgs, ... }: {
          system.stateVersion = "24.05";
          nix.settings.experimental-features = [ "flakes nix-command" ];
          wsl.enable = true;
          wsl.defaultUser = "fng";
          programs.fish.enable = true;
          users.defaultUserShell = pkgs.fish;
          # programs.nix-ld.enable = true;
          # wsl.startMenuLaunchers = true;
          virtualisation.docker.enable = true;
          users.users.fng.extraGroups = [ "docker" ];
        })

        home-manager.nixosModules.home-manager
        ({ config, pkgs, ... }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.fng = { imports = [ ./home.nix ./wsl.nix ]; };
          extraSpecialArgs = { inherit pkgs inputs; };
        })
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
