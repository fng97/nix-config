{ pkgs, inputs, ... }:

{
  home.stateVersion = "24.05";

  home.username = "fng";
  home.homeDirectory = "/home/fng";
  home.sessionVariables = { BROWSER = "wslview"; };

  home.packages = with pkgs; [
    inputs.nvim.packages.${system}.default
    nixfmt
    tlrc
    lazygit
    gh
    wslu # for wslview
  ];

  # TODO: remove fish greeting
  # TODO: bump starship timeout
  # TODO: remove "impure" in staship

  programs.home-manager.enable = true;
  programs.fish.enable = true;
  programs.starship.enable = true;

  home.file = {
    # See https://github.com/NixOS/nix/issues/1512. Supposedly fixed but will
    # keep using this hack for now.
    ".config/fish" = {
      source = ./fish;
      recursive = true;
    };
  };

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
