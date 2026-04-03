{ config, pkgs, ... }:

{
  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
  services.gnome.gnome-keyring.enable = true;
    systemd.services.fprintd = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "simple";
    };
}
