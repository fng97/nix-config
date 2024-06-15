{ config, pkgs, ... }:

{
  home.username = "fng";
  home.homeDirectory = "/home/fng";

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    # LazyVim
    ripgrep
    lazygit
    fd
  ];

  home.file = {
    ".config/nvim" = {
      source = ./nvim;
      recursive = true;
    };

    ".config/alacritty" = {
      source = ./alacritty;
      recursive = true;
    };

    ".zshrc".source = ./dotfiles/zshrc;
    ".p10k.zsh".source = ./dotfiles/p10k.zsh;
  };

  # Using nix to manage zsh led to an annoying completions permissions thing
  # I couln't fix so installing things manually for now and copying in a .zshrc
  # dotfile with nix

  # FIXME: Manually installing p10k with `brew install powerlevel10k`
  # FIXME: Manually installed omz
  # FIXME: Also manually did `brew install zsh-autosuggestions`

  home.sessionVariables = {
    EDITOR = "nvim";
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
