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
    lfs.enable = true;
    userName = "fng97";
    userEmail = "53615823+fng97@users.noreply.github.com";
    extraConfig = {
      push.autoSetupRemote = "true";
      init.defaultBranch = "main";
    };
  };
}
