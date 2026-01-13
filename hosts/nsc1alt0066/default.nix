{ config, lib, pkgs, pkgs-unstable, inputs, ... }:

{
  # Set computer name
  networking.hostName = "nsc1alt0066";

  # macOS-specific packages
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    yq-go
    stern
    kubectl-node-shell
    kubectl-view-allocations
    kubectl-cnpg
    kubectl-tree
    cilium-cli
    qemu
    (google-cloud-sdk.withExtraComponents (
      with google-cloud-sdk.components;
      [
        gke-gcloud-auth-plugin
      ]
    ))
  ] ++ (with pkgs-unstable; [
    vcluster
  ]);

  # System configuration version
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
}
