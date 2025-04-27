{ pkgs, config, ... }: {
  environment.systemPackages = [ pkgs.tailscale ];
  services.tailscale.enable = true;
  networking = {
    firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
      allowedTCPPorts = [ 22 ]; # allow SSH without tailscale
    };
  };
}
