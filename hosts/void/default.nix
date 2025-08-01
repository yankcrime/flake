{ config, lib, pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  networking.hostName = "void";

  # LUKS encryption specific to void
  boot.initrd.luks.devices = {
    crypted = {
      device = "/dev/disk/by-uuid/b388968a-5e47-4c19-b3a0-b6c5608be206";
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
  ] ++ (with pkgs-unstable; [
    vcluster
  ]);

  services.tailscale.enable = true;

}
