# Nix Config

## `macbook`

1. Install Nix with the [Determinate Installer](https://github.com/DeterminateSystems/nix-installer)
   - when prompted, make sure to use vanilla upstream Nix instead of Determinate Nix
2. Run `nix run nix-darwin/master#darwin-rebuild -- switch --flake github:fng97/nix-config#macbook`
3. To update with local changes to the flake run `nix-darwin switch --flake .#macbook`

## `wsl`

1. Install [NixOS-WSL](https://github.com/nix-community/NixOS-WSL)
2. Once in, run `sudo nix-channel --update` and `sudo nixos-rebuild switch` (not sure this is necessary but I do it anyway)
3. Switch to flake:
   ```bash
   sudo nixos-rebuild switch --flake github:fng97/nix-config#wsl
   ```
4. Use `wsl -s NixOS` to make it the default
5. To update with local changes to the flake run `sudo nixos-rebuild switch --flake .#wsl`

## Windows

1. Update everything with `winget upgrade --all`
2. PowerToys: enable Keyboard Manager (swap CAPS for CTRL), disable the rest
3. Copy `wezterm.lua` to `~/.config/wezterm` (_Windows_ home directory)
