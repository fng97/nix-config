# Home Manager

1. Install Nix using the Determinate installer
2. Clone this repo to `~/.config/home-manager` and from the root run:

   ```bash
   nix run home-manager/master -- switch --flake .
   ```

Run `chsh -s $(which fish)` if fish is not already the default shell.
