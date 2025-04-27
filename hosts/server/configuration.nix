{ pkgs, secrets, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./tailscale.nix
    (import ./networking.nix { inherit pkgs secrets; })
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "server";
  networking.domain = "";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys =
    [ secrets.server.ssh_public_key ];
  system.stateVersion = "23.11";
}
