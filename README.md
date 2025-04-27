# Nix Config

## `macbook`

1. Install Nix with the [Determinate Installer](https://github.com/DeterminateSystems/nix-installer)
   - when prompted, make sure to use vanilla upstream Nix instead of Determinate Nix
2. Run `nix run nix-darwin/master#darwin-rebuild -- switch --flake github:fng97/nix-config#macbook`
3. To update with local changes to the flake run `nix-darwin switch --flake .#macbook`

## `wsl`

1. Install [NixOS-WSL](https://github.com/nix-community/NixOS-WSL)
2. Once in, run `sudo nix-channel --update` and `sudo nixos-rebuild switch`
   (not sure this is necessary but I do it anyway)
3. Switch to flake:
   ```bash
   sudo nixos-rebuild switch --flake github:fng97/nix-config#wsl
   ```
4. Use `wsl -s NixOS` to make it the default
5. To update with local changes to the flake run `sudo nixos-rebuild switch --flake .#wsl`

## Windows

1. Update everything with `winget upgrade --all` and make sure `win32yank.exe`, WezTerm, and PowerToys are installed
2. PowerToys: enable Keyboard Manager (swap CAPS for CTRL), disable the rest
3. Copy `wezterm.lua` to `~/.config/wezterm` (_Windows_ home directory)

## `server`

Setting up a new server:

1. Provision the server and install NixOS (e.g. with [NixOS-Infect](https://github.com/elitak/nixos-infect))

   NOTE: A `configuration.nix` and `hardware-configuration.nix` will be generated for us based on the server.
   NixOS-Infect will additionally generate a `networking.nix` for us.

2. Retrieve the generated configuration: `scp -r root@<ip>:/etc/nixos hosts/server`
3. Replace the secrets with ones stored in `secrets/secrets.json` (`git-crypt`) and adjust the imports to include
   the tailscale module:

   ```nix
   imports = [
     ./hardware-configuration.nix
     ./tailscale.nix
     (import ./networking.nix { inherit secrets; })
   ];
   ```

4. Deploy the configuration:

   ```bash
   nix run nixpkgs#nixos-rebuild -- switch --fast --flake .#server \
       --target-host root@<ip> \
       --build-host root@<ip>
   ```

5. Over SSH, authenticate tailscale: `tailscale up --ssh`
6. In the tailscale dashboard, make sure the new machine's token will not expire

To deploy further changes to the configuration:

```bash
nix run nixpkgs#nixos-rebuild -- switch --fast --flake .#server \
    --target-host root@server \
    --build-host root@server
```
