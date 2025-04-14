{ pkgs, ... }:

{
  home.stateVersion = "24.05";
  home.username = "fng";
  home.sessionVariables.SHELL = "${pkgs.fish}/bin/fish";

  home.packages = with pkgs; [ nixfmt-classic tlrc lazygit gh television htop ];

  home.file.".config/wezterm" = {
    source = ./wezterm;
    recursive = true;
  };

  programs.home-manager.enable = true;
  programs.starship.enable = true;
  programs.fish.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      catppuccin-nvim
      nvim-treesitter.withAllGrammars
      telescope-nvim
      conform-nvim
      neo-tree-nvim
      lualine-nvim
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
