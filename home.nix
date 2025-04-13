{ pkgs, inputs, ... }:

{
  home.stateVersion = "24.05";

  home.username = "fng";

  home.packages = with pkgs; [
    inputs.nixvim.packages.${system}.default
    nixfmt-classic
    tlrc
    lazygit
    gh
    television
    htop
  ];

  home.file.".config/wezterm" = {
    source = ./wezterm;
    recursive = true;
  };

  programs.home-manager.enable = true;
  programs.starship.enable = true;
  programs.fish.enable = true;

  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.SHELL = "${pkgs.fish}/bin/fish";
  fonts.fontconfig.enable = true;

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
