{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim.url = "github:fng97/nixvim";
  };

  outputs = { nixpkgs, home-manager, ... }@inputs: {
    homeConfigurations."wsl" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      extraSpecialArgs = { inherit inputs; };
      modules = [ ./home.nix ./wsl.nix ];
    };
    homeConfigurations."macbook" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages."x86_64-darwin";
      extraSpecialArgs = { inherit inputs; };
      modules = [ ./home.nix ./macbook.nix ];
    };
  };
}
