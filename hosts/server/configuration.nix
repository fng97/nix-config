{ pkgs, config, secrets, adventus, website, ... }: {
  imports = [
    adventus.nixosModule
    website.nixosModule
    ./hardware-configuration.nix
    ./tailscale.nix
    (import ./networking.nix { inherit pkgs secrets; })
  ];

  # TODO: User "hardened.nix"
  # TODO: Check that does "systemd-analyze security"?

  environment.systemPackages = [ pkgs.tailscale ];

  services = {
    adventus = {
      enable = true;
      discordToken = secrets.adventus.discordToken;
    };

    website.enable = true;
    tailscale.enable = true;
  };

  networking = {
    firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
      # TODO: Change default SSH port.
      allowedTCPPorts = [ 22 80 433 ]; # allow SSH without tailscale
    };
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
