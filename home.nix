{ pkgs, inputs, ... }:

{
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    inputs.nvim.packages.${system}.default
    nixfmt
    markdownlint-cli2
    tlrc
    lazygit
    gh
  ];

  # TODO: remove fish greeting
  # TODO: bump starship timeout
  # TODO: remove "impure" in staship

  programs.home-manager.enable = true;
  programs.starship.enable = true;

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

  programs.fish = {
    enable = true;
    shellAliases = {
      lazyvim = ''
        if test (count $argv) -gt 0;
          nix run github:sei40kr/nix-lazyvim -- $argv; 
        else; 
          nix run github:sei40kr/nix-lazyvim; 
        end
      '';
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
