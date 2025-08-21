{ config, lib, pkgs, pkgs-unstable, inputs, ... }:

{
  # Set computer name
  networking.hostName = "deadline";

  # macOS-specific packages
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
  ];

  # System configuration version
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
}
