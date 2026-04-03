{ config, pkgs, ... }:

{
  # Set your time zone.
  time.timeZone = "Europe/Belgrade";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sr_RS.UTF-8";
    LC_IDENTIFICATION = "sr_RS.UTF-8";
    LC_MEASUREMENT = "sr_RS.UTF-8";
    LC_MONETARY = "sr_RS.UTF-8";
    LC_NAME = "sr_RS.UTF-8";
    LC_NUMERIC = "sr_RS.UTF-8";
    LC_PAPER = "sr_RS.UTF-8";
    LC_TELEPHONE = "sr_RS.UTF-8";
    LC_TIME = "sr_RS.UTF-8";
  };
}
