{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim = {
      url = "github:fng97/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
