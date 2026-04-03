{ config, pkgs, ... }:

{
  # Networking
  networking.hostName = "darko-pipekit";
  networking.networkmanager.enable = true;

  # Firewall
  networking.firewall = {
    enable = true;
    #allowedTCPPorts = [ 22 ];
  };

  # Pipekit hostfile
  networking.extraHosts =
  ''
    10.29.28.3 pipekit.example.com
    127.0.0.1 pipekit.local
  '';
}
