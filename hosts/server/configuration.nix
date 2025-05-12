{ pkgs, secrets, adventus, ... }: {
  imports = [
    adventus.nixosModule
    ./hardware-configuration.nix
    ./tailscale.nix
    (import ./networking.nix { inherit pkgs secrets; })
  ];

  services.adventus = {
    enable = true;
    discordToken = secrets.adventus.discordToken;
  };

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "server";
  networking.domain = "";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys =
    [ secrets.server.ssh_public_key ];
  system.stateVersion = "23.11";
}
