{ config, pkgs, ... }:

{
  # Enable CUPS to print documents.
  services = {
    printing = {
      enable = true;
      drivers = [ pkgs.gutenprint pkgs.brlaser ];
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
