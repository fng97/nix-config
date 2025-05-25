{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    # discord bot: see host 'server' below
    adventus.url = "github:fng97/adventus";
    adventus.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nixpkgs, home-manager, nix-darwin, nixos-wsl, adventus, ... }:
    let
      secrets =
        builtins.fromJSON (builtins.readFile "${self}/secrets/secrets.json");
    in {
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
            environment.systemPackages = [ pkgs.tailscale ];
            services.tailscale.enable = true;
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
            home-manager.extraSpecialArgs = { inherit pkgs; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.fng = {
              imports = [ ./home.nix ];
              home.sessionVariables.BROWSER = "wslview";
              home.packages = with pkgs; [ wslu wget ];
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
            home-manager.extraSpecialArgs = { inherit pkgs; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.fng = {
              imports = [ ./home.nix ];
              home.sessionVariables.BROWSER = "open";
            };
          }
        ];
      };

      nixosConfigurations.server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit secrets adventus; };
        modules = [ ./hosts/server/configuration.nix ];
      };

      nixosConfigurations.testvm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          adventus.nixosModule
          ({ pkgs, ... }: {
            fileSystems."/".label = "vmdisk"; # root filesystem label for QEMU
            networking.hostName = "vmhost";

            users.groups.vm = { };
            users.extraUsers.vm = {
              isNormalUser = true;
              password = "vm";
              shell = pkgs.bash;
              group = "vm";
              extraGroups = [ "wheel" ];
            };
            security.sudo.enable = true;
            security.sudo.wheelNeedsPassword = false;

            services.adventus = {
              enable = true;
              discordToken = secrets.adventus.discordToken;
            };
          })
        ];
      };
    };
}
