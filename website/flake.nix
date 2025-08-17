{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  inputs.zig2nix.url = "github:Cloudef/zig2nix";
  inputs.zig2nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, zig2nix, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
      mkForSystem = system: {
        pkgs = import nixpkgs { inherit system; };
        env = zig2nix.outputs.zig-env.${system} { };
      };
      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems (system: f (mkForSystem system));
    in {
      packages =
        forAllSystems ({ env, ... }: { default = env.package { src = ./.; }; });

      devShells = forAllSystems ({ env, ... }: { default = env.mkShell { }; });

      nixosModules.default = { pkgs, config, lib, ... }:
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
                root * ${
                  self.packages.${pkgs.stdenv.hostPlatform.system}.default
                }
                encode
                file_server
              '';
            };

            networking.firewall.allowedTCPPorts = [ 80 443 ];
          };
        };

      checks = forAllSystems ({ pkgs, ... }: {
        website-test = pkgs.nixosTest {
          name = "website-test";

          nodes.machine = { ... }: {
            imports = [ self.nixosModules.default ];
            services.website.enable = true;
          };

          testScript = ''
            machine.start()
            machine.wait_for_unit("caddy.service")
            # machine.wait_for_open_port(80)
            machine.succeed("curl -sSf http://localhost | grep -q 'Francisco Nevitt Gonçalves'")
          '';
        };
      });
    };
}
