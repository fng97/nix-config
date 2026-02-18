# Nix Config

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

## Website

Inspired by
[TigerBeetle's documentation](https://tigerbeetle.com/blog/2025-02-27-why-we-designed-tigerbeetles-docs-from-scratch/),
my personal website is built using the Zig build system as a static site generator. It uses Pandoc
to generate HTML from Markdown, with an extra step for generating an index and an `atom.xml`. The
tests validate the HTML and CSS, and check all links are reachable.

To build the website, run:

```sh
$ cd website
$ zig build # installs to zig-out
```
