{
  description = "NixOS configurations for void and carboforce";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs: 
  let
    system = "x86_64-linux";
    
    # Helper function to create a NixOS system with optional home-manager
    mkNixosSystem = { hostname, enableHomeManager ? true, extraModules ? [] }: 
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { 
          inherit inputs;
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };
        modules = [
          ./hosts/${hostname}
        ] ++ nixpkgs.lib.optionals enableHomeManager [
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nick = import ./modules/home-manager.nix;
          }
        ] ++ extraModules;
      };
  in
  {
    nixosConfigurations = {
      void = mkNixosSystem { 
        hostname = "void"; 
        enableHomeManager = true; 
      };

      carboforce = mkNixosSystem { 
        hostname = "carboforce"; 
        enableHomeManager = true; 
      };
    };
  };
}