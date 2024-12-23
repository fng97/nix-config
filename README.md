# Home Manager

1. Install Nix using the Determinate installer
2. Clone this repo to `~/.config/home-manager` and from the root run:

   ```bash
   nix run home-manager/master -- switch --flake .#fng
   ```
4. Run the following to make fish the default shell:

    ```bash
    which fish | sudo tee -a /etc/shells
    ```

    ```bash
    chsh -s $(which fish)
    ```
For moments of desperation: `nix run github:sei40kr/nix-lazyvim -- {file}`
