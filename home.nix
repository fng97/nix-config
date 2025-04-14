{ pkgs, ... }:

{
  home.stateVersion = "24.05";
  home.username = "fng";
  home.sessionVariables.SHELL = "${pkgs.fish}/bin/fish";
  programs.home-manager.enable = true;
  programs.starship.enable = true;
  programs.fish.enable = true;

  home.packages = with pkgs; [ nixfmt-classic tlrc lazygit gh television htop ];

  home.file.".config/wezterm" = {
    source = ./wezterm;
    recursive = true;
  };

  programs.neovim = let
    auto-dark-mode-nvim = pkgs.vimUtils.buildVimPlugin {
      name = "auto-dark-mode.nvim";
      src = pkgs.fetchFromGitHub {
        owner = "f-person";
        repo = "auto-dark-mode.nvim";
        rev = "c31de126963ffe9403901b4b0990dde0e6999cc6";
        sha256 = "sha256-ZCViqnA+VoEOG+Xr+aJNlfRKCjxJm5y78HRXax3o8UY=";
      };
    };
  in {
    enable = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      catppuccin-nvim
      nvim-treesitter.withAllGrammars
      telescope-nvim
      conform-nvim
      neo-tree-nvim
      lualine-nvim
      auto-dark-mode-nvim
    ];

    extraPackages = with pkgs; [
      ripgrep
      shfmt
      clang-tools
      cmake-format
      stylua
      rustfmt
      black
      nixfmt-classic
      nodePackages.prettier
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
