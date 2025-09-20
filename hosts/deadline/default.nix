{ config, lib, pkgs, pkgs-unstable, inputs, ... }:

{
  # Set computer name
  networking.hostName = "deadline";

  # macOS-specific packages
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    stern
    kubectl-node-shell
    kubectl-view-allocations
    kubectl-cnpg
    kubectl-tree
  ];

  # System configuration version
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
}
