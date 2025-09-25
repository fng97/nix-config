# Nix Config

Hello there! You've stumbled upon my [Nix](https://nixos.org) monorepo. I use it to manage all of my
tools and systems. It includes things like my [dotfiles](./dotfiles), NixOS system configurations,
and my [website](https://francisco.wiki) (see `.#website` and `.#server`). If you're curious about
anything here, feel free to reach out.

## `macbook`

1. Install Nix with the
   [Determinate Installer](https://github.com/DeterminateSystems/nix-installer).
   - When prompted, **make sure to use vanilla upstream Nix instead of Determinate Nix**.
2. Install (and update) [nix-darwin](https://github.com/nix-darwin/nix-darwin) with
   `sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#macbook`.

## Windows

1. Update everything with `winget upgrade --all` and make sure
   [`win32yank.exe`](https://github.com/equalsraf/win32yank), [WezTerm](https://wezterm.org), and
   [PowerToys](https://github.com/microsoft/PowerToys) are installed.
2. PowerToys: enable Keyboard Manager (swap CAPS for CTRL), enable FancyZones, and disable the rest.

## `wsl`

1. Install [NixOS-WSL](https://github.com/nix-community/NixOS-WSL).
2. Switch to flake: `sudo nixos-rebuild switch --flake .#wsl`
3. Copy `wezterm` folder to `~/.config/wezterm` (`~` here is the _Windows_ home directory).

## `server`

Setting up a new server:

1. Provision the server and install NixOS (e.g. with
   [NixOS-Infect](https://github.com/elitak/nixos-infect)). A `configuration.nix`, `networking.nix`,
   and `hardware-configuration.nix` will be generated for us.
2. Retrieve the generated configuration: `scp -r root@<ip>:/etc/nixos hosts/server` and update
   `.#server` to use it.
3. Update the secrets in `secrets/secrets.json` ([`git-crypt`](https://github.com/AGWA/git-crypt)).
4. Deploy the configuration:

   ```bash
   nix run nixpkgs#nixos-rebuild -- switch \
           --fast --flake .#server \
           --use-remote-sudo \
           --target-host root@server \
           --build-host root@server
   ```

5. Over SSH, authenticate [tailscale](https://tailscale.com): `tailscale up --ssh`.
6. In the tailscale dashboard, make sure the new machine's token will not expire.
