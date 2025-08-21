{ config, lib, pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/linux.nix
  ];

  networking.hostName = "rain";

  # Development VM specific packages
  environment.systemPackages = with pkgs; [
    # Additional development tools for VMs
  ];

  services.qemuGuest.enable = true;
  services.tailscale.enable = true;

}
