{ pkgs, secrets, ... }: {
  networking = {
    nameservers = [ "8.8.8.8" ];
    defaultGateway = secrets.server.ipv4_route;
    defaultGateway6 = {
      address = secrets.server.ipv6_route;
      interface = "eth0";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = pkgs.lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [{
          address = secrets.server.ipv4_address;
          prefixLength = 32;
        }];
        ipv6.addresses = [
          {
            address = secrets.server.ipv6_address_0;
            prefixLength = 64;
          }
          {
            address = secrets.server.ipv6_address_1;
            prefixLength = 64;
          }
        ];
        ipv4.routes = [{
          address = secrets.server.ipv4_route;
          prefixLength = 32;
        }];
        ipv6.routes = [{
          address = secrets.server.ipv6_route;
          prefixLength = 128;
        }];
      };

    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="${secrets.server.mac_address}", NAME="eth0"
  '';
}
