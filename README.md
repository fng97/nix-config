# Home Manager

My `home-manager` config. Currently only using this for WSL.

1. Install WSL with Ubuntu (comes with systemd enabled)
2. Install Nix and enable flakes
3. Clone this repo to `~/.config/home-manager` and run:

   ```bash
   nix shell nixpkgs#home-manager
   home-manager switch
   ```

FIXME: To get zsh working in WSL I had to run the following.

```bash
command -v zsh | sudo tee -a /etc/shells
sudo chsh -s /home/fng/.nix-profile/bin/zsh
chsh -s /home/fng/.nix-profile/bin/zsh
```

## Todos

- unify neovim and zellij pane movement
  - https://www.reddit.com/r/zellij/comments/18xz5ng/use_alt_for_keybinds_in_zellij_avoid_conflicts/
  - https://github.com/swaits/zellij-nav.nvim
- set up zellij scenes
  - dev tab with pane for nvim and pane for terminal
  - tab for notes
  - tab for home manager?
  - tab (or shortcut) for zellij keybinds
