{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    powertop
    throttled

    # Media (terminal-based)
    ncmpcpp
    rmpc
  ];

  services = {
    throttled.enable = true;
    mpd.user = "nick";
  };

  powerManagement.powertop.enable = true;
}
