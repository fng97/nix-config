# Home Manager

Some notes for setting up my system while I take a break from Nix.

I'll either move to managing config with dotfiles and set up stow or go back to
home-manager (but with nix-darwin). Doing this for now because I'm still scarred
from trying to get my nix config working on both linux_x86-64 and darwin_aarc64.

## Terminal Stuff

- install alacritty
- set alacritty config
- install omz
- install zsh-autosuggestions
- install zsh-syntax-highlighting
- install and set up p10k theme
- install lazyvim
- make nvim default: add `export EDITOR=nvim` to .zshrc

### Alacritty Config

```toml
[env]
TERM = "xterm-256color"

[window]
padding.x = 10
padding.y = 10

decorations = "buttonless"

[font]
normal.family = "JetBrainsMono Nerd Font"
normal.style = "Regular"
size = 16

[colors]
# manually setting background to match nvim
# used `:hi Normal` and used guibg value
primary.background = "#222436"

[keyboard]
bindings = [
  # move/delete words at a time
  { key = "Right", mods = "Alt", chars = "\u001BF" },
  { key = "Left", mods = "Alt", chars = "\u001BB" },
]
```

## MacOS Stuff

- max out key repeat rate and minimise key repeat delay
- repeate keys in VSCode instead of special character pop-up:

  ```zsh
  defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
  ```

## `git` Stuff

Sort this stuff out manually.

```nix
  programs.git = {
    enable = true;
    userName = "fng97";
    userEmail = "53615823+fng97@users.noreply.github.com";
    extraConfig = {
      push.autoSetupRemote = "true";
      init.defaultBranch = "main";
    };
  };
```
