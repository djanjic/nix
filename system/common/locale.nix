{ config, pkgs, ... }:

{
  # Set your time zone.
  time.timeZone = "Europe/Belgrade";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_RS.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_RS.UTF-8";
    LC_IDENTIFICATION = "en_RS.UTF-8";
    LC_MEASUREMENT = "en_RS.UTF-8";
    LC_MONETARY = "en_RS.UTF-8";
    LC_NAME = "en_RS.UTF-8";
    LC_NUMERIC = "en_RS.UTF-8";
    LC_PAPER = "en_RS.UTF-8";
    LC_TELEPHONE = "en_RS.UTF-8";
    LC_TIME = "en_RS.UTF-8";
  };
}
