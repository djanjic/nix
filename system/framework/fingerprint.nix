{ config, pkgs, ... }:

{
  services.fprintd.enable = true;
  #services.fprintd.tod.enable = true;
#  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;
  #security.pam.services.login.fprintAuth = true;
  #services.gnome.gnome-keyring.enable = true;
    #systemd.services.fprintd = {
      #wantedBy = [ "multi-user.target" ];
      #serviceConfig.Type = "simple";
    #};
}
