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
    yq
    stern
    kubectl-node-shell
    kubectl-view-allocations
    kubectl-cnpg
    kubectl-tree
    nixos-generators
    (google-cloud-sdk.withExtraComponents (
      with google-cloud-sdk.components;
      [
        gke-gcloud-auth-plugin
      ]
    ))
  ] ++ (with pkgs-unstable; [
    vcluster
  ]);

  services.tailscale.enable = true;

}
