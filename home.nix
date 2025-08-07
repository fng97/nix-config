{ pkgs, ... }:

let
  jrnl = pkgs.stdenv.mkDerivation {
    name = "jrnl";
    src = ./jrnl.zig;
    dontUnpack = true;
    nativeBuildInputs = [ pkgs.zig ];
    # The global Zig cache dir is not accessible in the sandbox so we use "./cache".
    installPhase = ''
      mkdir -p $out/bin .cache
      zig build-exe --global-cache-dir .cache -O ReleaseSafe -femit-bin=$out/bin/jrnl $src
    '';
  };
in {
  home.stateVersion = "24.05";
  home.username = "fng";
  home.sessionVariables.SHELL = "${pkgs.fish}/bin/fish";
  programs.fish.enable = true;

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
      source = ./wezterm;
      recursive = true;
    };

    ".newsboat/urls".source = ./newsboat/urls;
  };

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
      conform-nvim
      nvim-lspconfig
      gitsigns-nvim
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

    extraLuaConfig = pkgs.lib.fileContents ./nvim/init.lua;
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
}
