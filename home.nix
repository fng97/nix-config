{ pkgs, inputs, ... }:

{
  home.stateVersion = "24.05";
  home.username = "fng";
  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.SHELL = "${pkgs.fish}/bin/fish";

  home.packages = with pkgs; [
    inputs.nixvim.packages.${system}.default
    nerd-fonts.jetbrains-mono
    nixfmt-classic
    markdownlint-cli
    tlrc
    lazygit
    gh
    television
    bitwarden-cli
    htop

    # install some build tools by default
    cmake
    ccache
    python313
    zig
    rustup
  ];

  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;
  programs.starship.enable = true;
  programs.fish.enable = true;

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

  programs.vscode = {
    enable = true;
    # extensions = [];
    # userSettings = ;
  };
}
