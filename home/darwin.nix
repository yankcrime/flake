{ config, pkgs, pkgs-unstable, ... }:

let
  commonPackages = import ./common.nix { inherit config pkgs pkgs-unstable; };
in
{
  imports = [
    ./home-manager.nix
  ];
  
  home.packages = commonPackages.shared; 

}
