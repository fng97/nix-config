{ config, pkgs, ... }:

{
  home.username = "fng";
  home.homeDirectory = "/home/fng";

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    wslu # for wslview
    gh

    # for LazyVim
    lazygit
    ripgrep
    fd
    gcc
    markdownlint-cli
    unzip
    nodejs
    python3
    rustup # FIXME: had to run `rustup default stable` manually
  ];

  home.file = {
    ".config/nvim" = {
      source = ./nvim;
      recursive = true;
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    SHELL = "${pkgs.zsh}/bin/zsh";
    BROWSER = "wslview";
  };

  programs.zsh = {
    enable = true;

    oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
    };

    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  programs.git = {
    enable = true;
    userName = "fng97";
    userEmail = "53615823+fng97@users.noreply.github.com";
    extraConfig = {
      push.autoSetupRemote = "true";
      init.defaultBranch = "main";
    };
  };

  programs.home-manager.enable = true;
}
