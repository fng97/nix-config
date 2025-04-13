{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "github:fng97/nixvim";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, home-manager, nix-darwin, nixos-wsl, ... }@inputs: {

      nixosConfigurations.wsl = let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
      in nixpkgs.lib.nixosSystem {
        inherit system;
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
            home-manager.extraSpecialArgs = { inherit inputs pkgs; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.fng = {
              imports = [ ./home.nix ];
              home.sessionVariables.BROWSER = "wslview";
              home.packages = with pkgs; [ wslu ];
            };
          }
        ];
      };

      darwinConfigurations.macbook = let
        system = "aarch64-darwin";
        pkgs = nixpkgs.legacyPackages.${system};
      in nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          {
            system.stateVersion = 5;
            environment.systemPackages = with pkgs; [ tailscale wezterm ];
            services.tailscale.enable = true;
            nix.settings.experimental-features = "nix-command flakes";
            programs.fish.enable = true;
            system.configurationRevision = self.rev or self.dirtyRev or null;
            users.users.fng.home = "/Users/fng";
            users.users.fng.shell = pkgs.fish;
          }
          home-manager.darwinModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit inputs pkgs; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.fng = {
              imports = [ ./home.nix ];
              home.sessionVariables.BROWSER = "open";
            };
          }
        ];
      };
    };
}
