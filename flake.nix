{
  description = "NixOS configurations for various machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = {
    self,
    nixpkgs,
    ghostty,
    nixpkgs-unstable,
    home-manager,
    darwin,
    ...
  }@inputs:
  let
    linuxSystem = "x86_64-linux";
    darwinSystem = "aarch64-darwin";
    
    # Helper function to create a NixOS system with optional home-manager and GUI
    mkNixosSystem = { hostname, enableHomeManager ? true, enableGUI ? true, extraModules ? [] }: 
      nixpkgs.lib.nixosSystem {
        system = linuxSystem;
        specialArgs = { 
          inherit inputs;
          pkgs-unstable = import nixpkgs-unstable {
            system = linuxSystem;
            config.allowUnfree = true;
          };
        };
        modules = [
          ./hosts/${hostname}
          ./modules/gui.nix
          {
            modules.gui.enable = enableGUI;
          }
        ] ++ nixpkgs.lib.optionals enableHomeManager [
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nick = import ./modules/home-manager-linux.nix;
          }
        ] ++ extraModules;
      };

    # Helper function to create a Darwin system
    mkDarwinSystem = { hostname, enableHomeManager ? true }: 
      darwin.lib.darwinSystem {
        system = darwinSystem;
        specialArgs = { 
          inherit inputs;
          pkgs-unstable = import nixpkgs-unstable {
            system = darwinSystem;
            config.allowUnfree = true;
          };
        };
        modules = [
          ./hosts/${hostname}
          ./modules/darwin.nix
        ] ++ nixpkgs.lib.optionals enableHomeManager [
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nick = import ./modules/home-manager-darwin.nix;
          }
        ];
      };
  in
  {
    nixosConfigurations = {
      void = mkNixosSystem { 
        hostname = "void"; 
        enableHomeManager = true;
        enableGUI = true;
      };

      carboforce = mkNixosSystem { 
        hostname = "carboforce"; 
        enableHomeManager = true;
        enableGUI = true;
      };

      # Headless development VM
      rain = mkNixosSystem {
        hostname = "rain";
        enableHomeManager = true;
        enableGUI = false;
      };
    };

    darwinConfigurations = {
      deadline = mkDarwinSystem {
        hostname = "deadline";
        enableHomeManager = true;
      };
    };
    darwinConfigurations = {
      nsc1alt0066 = mkDarwinSystem {
        hostname = "nsc1alt0066";
        enableHomeManager = true;
      };
    };
  };
}
