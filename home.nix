{ config, pkgs, ... }:

{
  home.username = "fng";
  home.homeDirectory = "/Users/fng";

  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    # LazyVim
    ripgrep
    lazygit
    fd
    nodejs_21
  ];

  programs.zsh.enable = true;

  programs.alacritty.enable = true;
  programs.alacritty.settings = {
    window = {
      padding.x = 18;
      padding.y = 16;
      decorations = "buttonless";
    };

    font = {
      normal.family = "SFMono Nerd Font";
      normal.style = "Regular";
      size = 22;
    };
  };

  programs.starship.enable = true;

  home.file = {
    ".config/nvim" = {
      source = ./nvim;
      recursive = true;
    };
  };

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
