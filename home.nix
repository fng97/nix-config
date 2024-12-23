{ pkgs, inputs, ... }:

{
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    inputs.nixvim.packages.${system}.default
    nixfmt-classic
    markdownlint-cli
    tlrc
    lazygit
    gh
  ];

  # TODO: remove fish greeting
  # TODO: bump starship timeout
  # TODO: remove "impure" in staship

  programs.home-manager.enable = true;
  programs.starship.enable = true;
  programs.fish.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  home.file = {
    # See https://github.com/NixOS/nix/issues/1512. Supposedly fixed but will
    # keep using this hack for now.
    ".config/fish" = {
      source = ./fish;
      recursive = true;
    };
    ".config/alacritty" = {
      source = ./alacritty;
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
