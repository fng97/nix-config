{ pkgs, ... }:

{
  home.stateVersion = "24.05";

  home.username = "fng";
  home.homeDirectory = "/home/fng";
  home.sessionVariables = { BROWSER = "wslview"; };

  home.packages = with pkgs; [
    wslu # for wslview
    gh
    tlrc
    nixfmt

    # for LazyVim
    lazygit
    ripgrep
    fd
    gcc
    markdownlint-cli
    ruff
    unzip
    nodejs
    rustup # FIXME: had to run `rustup default stable` manually
  ];

  programs.home-manager.enable = true;
  programs.fish.enable = true;
  programs.starship.enable = true;

  home.file = {
    # TODO: move out nvim config into separate flake
    ".config/nvim" = {
      source = ./nvim;
      recursive = true;
    };
    # See https://github.com/NixOS/nix/issues/1512. Supposedly fixed but will
    # keep using this hack for now.
    ".config/fish" = {
      source = ./fish;
      recursive = true;
    };
  };

  # FIXME: why do I need this? for a nvim dep?
  home.sessionPath = [ "$HOME/.local/bin" ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "fng97";
    userEmail = "53615823+fng97@users.noreply.github.com";
    extraConfig = {
      push.autoSetupRemote = "true";
      init.defaultBranch = "main";
    };
  };
}
