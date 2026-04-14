{ config, pkgs, ... }:

{
  # Podman (rootless containers with Docker compat)
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;        # alias docker -> podman
    dockerSocket.enable = true; # emulate Docker socket for tools that need it
    defaultNetwork.settings.dns_enabled = true;
  };

  users.extraGroups.podman.members = [ "darko" ];
}
