{ config, pkgs, ... }:

{
  home.username = "fng";
  home.homeDirectory = "/home/fng";

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    wslu # for wslview
    gh
    zsh-powerlevel10k
    nerdfetch

    # TODO: learn how to use nix dev shells for project deps that inherit
    # environment with direnv
    cmake
    poetry
    ninja
    ccache
    gcc-arm-embedded
    gnumake
    # FIXME: had to remove clang here and install it with apt. Otherwise it
    # clashes with gcc.
    clang-tools

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
    ".config/zellij" = {
      source = ./zellij;
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

    oh-my-zsh.enable = true;

    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = ./p10k;
        file = "p10k.zsh";
      }
    ];

    shellAliases = {
      gitsync = ''
        git pull --rebase &&
        git add . &&
        git commit -m "Sync: $(date '+%Y-%m-%d %H:%M:%S')" &&
        git push
      '';
    };

    initExtra = "nerdfetch";
  };

  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
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
