{ config, pkgs, ... }:

{
  home.username = "fng";
  home.homeDirectory = "/Users/fng";

  home.stateVersion = "23.11";

  home.packages = [
    # install stuff here
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "fng97";
    userEmail = "53615823+fng97@users.noreply.github.com";
  };
}
