{ config, pkgs, ... }:

{
  # Set your time zone.
  time.timeZone = "Europe/Belgrade";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "sr_RS/UTF-8"
  ];

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sr_RS";
    LC_IDENTIFICATION = "sr_RS";
    LC_MEASUREMENT = "sr_RS";
    LC_MONETARY = "sr_RS";
    LC_NAME = "sr_RS";
    LC_NUMERIC = "sr_RS";
    LC_PAPER = "sr_RS";
    LC_TELEPHONE = "sr_RS";
    LC_TIME = "sr_RS";
  };
}
