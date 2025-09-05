{ config, pkgs, pkgs-unstable, ... }:

let
  commonPackages = import ../modules/common.nix { inherit config pkgs pkgs-unstable; };
in
{
  imports = [
    ./home-manager.nix
  ];
  
  home.packages = commonPackages.shared; 

}
