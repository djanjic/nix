{ config, pkgs, ... }:

{
  # Docker
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      insecure-registries = [ "k3d-registry.localhost:5000" ];
    };
  };

  users.extraGroups.docker.members = [ "darko" ];
}
