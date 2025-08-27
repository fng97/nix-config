{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/release-25.05";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    adventus.url = "github:fng97/adventus";
    adventus.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, nix-homebrew, nixos-wsl
    , adventus, ... }:
    let
      secrets =
        builtins.fromJSON (builtins.readFile "${self}/secrets/secrets.json");

      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
      forSupportedSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      packages = forSupportedSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          website = pkgs.stdenv.mkDerivation {
            name = "website";
            src = ./website;
            nativeBuildInputs = [ pkgs.zig ];
            buildInputs = [ pkgs.pandoc ];
            XDG_CACHE_HOME = ".cache";
            installPhase = "zig build --prefix $out install";
          };
        });

      devShells = forSupportedSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default =
            pkgs.mkShell { buildInputs = with pkgs; [ zig zls pandoc ]; };
        });

      nixosModules.website = { pkgs, config, lib, ... }:
        let cfg = config.services.website;
        in {
          options.services.website = {
            enable = lib.mkEnableOption "Enable website";

            domain = lib.mkOption {
              type = lib.types.str;
              default = "http://localhost"; # for testing
              description = "The domain name Caddy should serve.";
            };

          };

          config = lib.mkIf cfg.enable {
            services.caddy = {
              enable = true;
              virtualHosts.${cfg.domain}.extraConfig = ''
                root * ${self.packages.${pkgs.system}.website}
                encode
                file_server
              '';
            };

            networking.firewall.allowedTCPPorts = [ 80 443 ];
          };
        };

      # checks = forAllSystems ({ pkgs, ... }: {
      #   website-test = pkgs.nixosTest {
      #     name = "website-test";
      #
      #     nodes.machine = { ... }: {
      #       imports = [ self.nixosModules.website ];
      #       services.website.enable = true;
      #     };
      #
      #     testScript = ''
      #       machine.start()
      #       machine.wait_for_unit("caddy.service")
      #       # machine.wait_for_open_port(80)
      #       machine.succeed("curl -sSf http://localhost | grep -q 'Francisco Nevitt Gonçalves'")
      #     '';
      #   };
      # });

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
            security.pki.certificateFiles = [ ./secrets/pwrootca1.crt ];
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
            environment.systemPackages = with pkgs; [ tailscale ];
            services.tailscale.enable = true;
            nix.settings.experimental-features = "nix-command flakes";
            nix.linux-builder = {
              enable = true;
              ephemeral = true;
              maxJobs = 4;
              config = {
                virtualisation = {
                  darwin-builder.memorySize = 8 * 1024;
                  cores = 6;
                };
              };
            };
            programs.fish.enable = true;
            system.configurationRevision = self.rev or self.dirtyRev or null;
            system.primaryUser = "fng";
            users.users.fng.home = "/Users/fng";
            users.users.fng.shell = pkgs.fish;
            homebrew = {
              enable = true;
              onActivation.cleanup = "uninstall";
              onActivation.upgrade = true;
              casks = [ "wezterm" "signal" "firefox" ];
            };
            security.pam.services.sudo_local.touchIdAuth = true;
          }

          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "fng";
            };
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
        modules = [
          ./hosts/server/configuration.nix
          self.nixosModules.website
          {
            services.website = {
              enable = true;
              domain = "francisco.wiki";
            };
          }
        ];
      };

      nixosConfigurations.testvm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          adventus.nixosModule
          self.nixosModules.website
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

            services = {
              website.enable = true;

              adventus = {
                enable = true;
                discordToken = secrets.adventus.discordToken;
              };
            };
          })
        ];
      };
    };
}
