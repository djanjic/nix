{ config, pkgs, ... }:

{
  # Set your time zone.
  time.timeZone = "Europe/Belgrade";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "sr_RS.utf8@latin"
  ];

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sr_RS.utf8@latin";
    LC_IDENTIFICATION = "sr_RS.utf8@latin";
    LC_MEASUREMENT = "sr_RS.utf8@latin";
    LC_MONETARY = "sr_RS.utf8@latin";
    LC_NAME = "sr_RS.utf8@latin";
    LC_NUMERIC = "sr_RS.utf8@latin";
    LC_PAPER = "sr_RS.utf8@latin";
    LC_TELEPHONE = "sr_RS.utf8@latin";
    LC_TIME = "sr_RS.utf8@latin";
  };
}
