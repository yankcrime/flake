{ config, lib, pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  networking.hostName = "void";
  networking.firewall.enable = false;
  networking.hosts = {
    "172.18.0.4" = [
      "console.unikorn.nscale.com"
      "identity.unikorn.nscale.com"
      "region.unikorn.nscale.com"
      "api.unikorn.nscale.com"
      "compute.unikorn.nscale.com"
    ];
  };

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
    cilium-cli
    nixos-generators
    fprintd
    iptables
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
  services.fprintd.enable = true;

}
