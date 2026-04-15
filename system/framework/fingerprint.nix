{ config, pkgs, ... }:

{
  services.fprintd.enable = true;
  #services.fprintd.tod.enable = true;
  #services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

  # GDM handles fingerprint login on its own (sets login.fprintAuth = false internally)
  # Only enable fprintAuth for services that don't conflict with GDM
  security.pam.services.sudo.fprintAuth = true;
  security.pam.services.polkit-1.fprintAuth = true;
}
