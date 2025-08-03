{ config, lib, pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  networking.hostName = "carboforce";

  # LUKS encryption specific to carboforce
  boot.initrd.luks.devices = {
    crypted = {
      device = "/dev/disk/by-uuid/f5ee096a-7562-4877-80e5-652a0c9c3143";
      preLVM = true;
      allowDiscards = true;
    };
  };

  environment.systemPackages = with pkgs; [
    stern
    kubectl-node-shell
    kubectl-view-allocations
    kubectl-cnpg
    kubectl-tree
    nixos-generators
    gnome-software
  ] ++ (with pkgs-unstable; [
    vcluster
  ]);

  services.tailscale.enable = true;

}
