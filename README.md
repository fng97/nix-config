# Nix Config

## macOS

1. Install Nix with the [Determinate Installer](https://github.com/DeterminateSystems/nix-installer)
2. Run `nix run home-manager/master -- switch --flake github:fng97/nix-config`
3. For local changes to the flake use `home-manager switch --flake .`

## WSL

1. Install [NixOS-WSL](https://github.com/nix-community/NixOS-WSL)
2. Once in, run `sudo nix-channel --update` and `sudo nixos-rebuild switch` (not sure this is necessary but I do it anyway)
3. Switch to flake:
   ```bash
   sudo nixos-rebuild switch --flake github:fng97/nix-config#wsl
   ```
4. Use `wsl -s NixOS` to make it the default
5. For local changes to the flake use `sudo nixos-rebuild switch --flake .#wsl`

## Windows

1. Update everything with `winget upgrade --all`
2. Install [scoop](https://scoop.sh/)
3. Install the following with scoop:
   - `firefox`
   - `wezterm`
   - `powertoys`
   - `win32yank`
   - `twinkle-tray`
4. PowerToys: enable PowerToys Run and Keyboard Manager (swap CAPS for CTRL), disable the rest
5. Copy `wezterm.lua` to `~/.config/wezterm` (_Windows_ home directory)
