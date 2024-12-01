{ pkgs, ... }:

{
  home.username = "fng";
  home.homeDirectory = "/home/fng";

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    wslu # for wslview
    gh
    zsh-powerlevel10k
    tlrc
    nixfmt

    # for LazyVim
    lazygit
    ripgrep
    fd
    gcc
    markdownlint-cli
    ruff
    unzip
    nodejs
    rustup # FIXME: had to run `rustup default stable` manually
  ];

  home.file = {
    # FIXME: move configuration below using vimPlugins.LazyVim?
    ".config/nvim" = {
      source = ./nvim;
      recursive = true;
    };
    # FIXME: move configuration below
    ".config/zellij" = {
      source = ./zellij;
      recursive = true;
    };
  };

  home.sessionVariables = {
    SHELL = "${pkgs.zsh}/bin/zsh";
    BROWSER = "wslview";
  };

  # FIXME: why do I need this?
  home.sessionPath = [ "$HOME/.local/bin" ];

  home.shellAliases = {
    gitsync = ''
      git pull &&
      git add . &&
      git commit -m "Sync: $(date '+%Y-%m-%d %H:%M:%S')" &&
      git push
    '';
    journal = ''
      filename=~/notes/journal/$(date +%Y-%m-%d).md
      if [[ -f "$filename" ]]; then
        vim "$filename"
      else
        echo "# $(date '+%A, %-d %B %Y')" > "$filename"
        vim "$filename"
      fi
    '';
  };

  # TODO: look into alacritty + fish + starship instead of omz+p10k. 
  # Want something as close to default as possible.
  programs.zsh = {
    enable = true;

    oh-my-zsh.enable = true;

    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = ./p10k;
        file = "p10k.zsh";
      }
    ];
  };

  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
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
    lfs.enable = true;
    userName = "fng97";
    userEmail = "53615823+fng97@users.noreply.github.com";
    extraConfig = {
      push.autoSetupRemote = "true";
      init.defaultBranch = "main";
    };
  };

  programs.home-manager.enable = true;
}
