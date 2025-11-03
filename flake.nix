{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    adventus.url = "github:fng97/adventus";
    adventus.inputs.nixpkgs.follows = "nixpkgs";
    zig-overlay.url = "github:mitchellh/zig-overlay";
    zig-overlay.inputs.nixpkgs.follows = "nixpkgs";
    zls-overlay.url = "github:zigtools/zls?ref=0.15.0";
    zls-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      adventus,
      zig-overlay,
      zls-overlay,
      ...
    }:
    let
      secrets = builtins.fromJSON (builtins.readFile "${self}/secrets/secrets.json");

      websiteNixosModule =
        {
          pkgs,
          config,
          lib,
          ...
        }:
        let
          cfg = config.services.website;
        in
        {
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

            networking.firewall.allowedTCPPorts = [
              80
              443
            ];
          };
        };

      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = [
            zig-overlay.overlays.default
            (final: prev: {
              zig = final.zigpkgs."0.15.1";
              zls = zls-overlay.packages.${system}.default;
            })
          ];
        };

      forSupportedSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forSupportedSystems (
        system:
        let
          pkgs = mkPkgs system;
        in
        {
          website = pkgs.stdenv.mkDerivation {
            name = "website";
            src = ./website;
            ZIG_GLOBAL_CACHE_DIR = ".cache";
            # Put validator-nu here so it's propagated to shell below. Wouldn't have to do this if
            # doCheck was set but it always fails on the server.
            nativeBuildInputs = with pkgs; [
              zig
              pandoc
              validator-nu
            ];
            buildPhase = "zig build install --prefix $out";
            dontInstall = true; # installed during build phase
            checkPhase = "zig build test";
          };
        }
      );

      devShells = forSupportedSystems (
        system:
        let
          pkgs = mkPkgs system;
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [ zls ];
            inputsFrom = [ self.packages.${pkgs.system}.website ];
          };
        }
      );

      nixosConfigurations.server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit secrets adventus; };
        modules = [
          ./hosts/server/configuration.nix
          websiteNixosModule

          {
            services.website = {
              enable = true;
              domain = "francisco.wiki";
            };
          }
        ];
      };

      nixosConfigurations.serverTestVm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          adventus.nixosModule
          websiteNixosModule

          (
            { pkgs, ... }:
            {
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
                  # TODO: Swap this for the test bot token.
                  discordToken = secrets.adventus.discordToken;
                };
              };
            }
          )
        ];
      };
    };
}
