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

      websiteNixosModule = { pkgs, config, lib, ... }:
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

      # TODO: Drop home-manager dependency for simple dotfiles.
      commonHomeManagerModule = { pkgs, ... }:
        let
          jrnl = pkgs.stdenv.mkDerivation {
            name = "jrnl";
            src = ./jrnl.zig;
            dontUnpack = true;
            nativeBuildInputs = [ pkgs.zig ];
            XDG_CACHE_HOME = ".cache";
            installPhase = ''
              mkdir -p $out/bin .cache
              zig build-exe -O ReleaseSafe -femit-bin=$out/bin/jrnl $src
            '';
          };
        in {
          home.stateVersion = "24.05";
          home.username = "fng";

          home.packages = with pkgs; [
            tlrc
            lazygit
            jrnl
            gh
            newsboat
            htop
            git-crypt
            zig
            zls
          ];

          home.file = {
            ".config/wezterm" = {
              source = ./dotfiles/wezterm;
              recursive = true;
            };
            ".newsboat/urls".source = ./dotfiles/newsboat/urls;
          };

          # TODO: Move nvim out into package/app.
          programs.neovim = let
            auto-dark-mode = pkgs.vimUtils.buildVimPlugin {
              name = "auto-dark-mode.nvim";
              src = pkgs.fetchFromGitHub {
                owner = "f-person";
                repo = "auto-dark-mode.nvim";
                rev = "c31de126963ffe9403901b4b0990dde0e6999cc6";
                sha256 = "sha256-ZCViqnA+VoEOG+Xr+aJNlfRKCjxJm5y78HRXax3o8UY=";
              };
            };
            vscode-theme = pkgs.vimUtils.buildVimPlugin {
              name = "vscode.nvim";
              src = pkgs.fetchFromGitHub {
                owner = "Mofiqul";
                repo = "vscode.nvim";
                rev = "4d1c3c64d1afddd7934fb0e687fd9557fc66be41";
                sha256 = "sha256-y0qtA7cGkzT+OqnvRfZhyvKgAS1PdkdvElsHEErAhyo=";
              };
            };
          in {
            enable = true;
            defaultEditor = true;

            plugins = with pkgs.vimPlugins; [
              auto-dark-mode
              vscode-theme
              nvim-treesitter.withAllGrammars
              telescope-nvim
              telescope-fzf-native-nvim
              telescope-file-browser-nvim
              conform-nvim
              nvim-lspconfig
              gitsigns-nvim
              lualine-nvim
            ];

            extraPackages = with pkgs; [
              ripgrep
              fd
              shfmt
              clang-tools
              cmake-format
              rust-analyzer
              stylua
              rustfmt
              nixfmt-classic
              jq
              nodePackages.prettier
              ruff
              nixd
              python312Packages.python-lsp-server
              lua-language-server
            ];

            extraLuaConfig = pkgs.lib.fileContents ./dotfiles/nvim/init.lua;
          };

          programs.direnv = {
            enable = true;
            nix-direnv.enable = true;
          };

          programs.git = {
            enable = true;
            userName = "fng97";
            userEmail = "fng97@icloud.com";
            lfs.enable = true;
            extraConfig.push.autoSetupRemote = "true";
            extraConfig.init.defaultBranch = "main";
          };
        };

      commonNixosModule = { pkgs, ... }: {
        nix.settings.experimental-features = "nix-command flakes";
        programs.fish.enable = true;
        programs.fish.interactiveShellInit = "set fish_greeting";
        programs.bash.interactiveShellInit =
          builtins.readFile ./dotfiles/bashrc_launch_fish.sh;
        programs.zsh.interactiveShellInit =
          builtins.readFile ./dotfiles/zsh_launch_fish.sh;
        home-manager.extraSpecialArgs = { inherit pkgs; };
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      };

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

      # TODO: Re-enable this check and write one that tests both the Discord bot and the website.
      # checks = forAllSystems ({ pkgs, ... }: {
      #   website-test = pkgs.nixosTest {
      #     name = "website-test";
      #
      #     nodes.machine = { ... }: {
      #       imports = [ websiteNixosModule ];
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
          commonNixosModule
          nixos-wsl.nixosModules.default
          home-manager.nixosModules.home-manager

          {
            system.stateVersion = "24.05";
            wsl.enable = true;
            wsl.defaultUser = "fng";
            wsl.startMenuLaunchers = true;
            users.users.fng.extraGroups = [ "docker" ];
            virtualisation.docker.enable = true;
            programs.nix-ld.enable = true;
            security.pki.certificateFiles = [ ./secrets/pwrootca1.crt ];
            home-manager.users.fng = {
              imports = [ commonHomeManagerModule ];
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
          commonNixosModule
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager

          {
            system.stateVersion = 5;
            system.configurationRevision = self.rev or self.dirtyRev or null;
            system.primaryUser = "fng";
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
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "fng";
            };
            homebrew = {
              enable = true;
              onActivation.cleanup = "uninstall";
              onActivation.upgrade = true;
              casks = [ "wezterm" "signal" "firefox" ];
            };
            environment.systemPackages = with pkgs; [ tailscale ];
            services.tailscale.enable = true;
            security.pam.services.sudo_local.touchIdAuth = true;
            users.users.fng.home = "/Users/fng";
            home-manager.users.fng = {
              imports = [ commonHomeManagerModule ];
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
                # TODO: Swap this for the test bot token.
                discordToken = secrets.adventus.discordToken;
              };
            };
          })
        ];
      };
    };
}
