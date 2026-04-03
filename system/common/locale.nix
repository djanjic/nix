{ config, pkgs, ... }:

{
  # Set your time zone.
  time.timeZone = "Europe/Belgrade";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "sr_RS@latin/UTF-8"
  ];

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sr_RS@latin";
    LC_IDENTIFICATION = "sr_RS@latin";
    LC_MEASUREMENT = "sr_RS@latin";
    LC_MONETARY = "sr_RS@latin";
    LC_NAME = "sr_RS@latin";
    LC_NUMERIC = "sr_RS@latin";
    LC_PAPER = "sr_RS@latin";
    LC_TELEPHONE = "sr_RS@latin";
    LC_TIME = "sr_RS@latin";
  };
}
