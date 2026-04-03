{ config, pkgs, ... }:

{
  imports = [
    <nixos-hardware/framework/13-inch/amd-ai-300-series>
    ./hardware-configuration.nix
    ./network.nix
    ./twingate.nix
    ../common/common.nix
  ];

  # Bootloader (UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.consoleLogLevel = 3;  # suppress UCSI/USB-C kernel warnings on login screen

  systemd.services.battery-charge-limit = {
    description = "Restore battery charge limit";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-udev-settle.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      LIMIT=50
      if [ -f /etc/battery-charge-limit ]; then
        LIMIT=$(cat /etc/battery-charge-limit)
      fi
      echo "$LIMIT" > /sys/class/power_supply/BAT1/charge_control_end_threshold
    '';
  };
  security.sudo.extraRules = [{
    users = [ "darko" ];
    commands = [
      {
        command = "${pkgs.coreutils}/bin/tee /sys/class/power_supply/BAT1/charge_control_end_threshold";
        options = [ "NOPASSWD" ];
      }
      {
        command = "${pkgs.coreutils}/bin/tee /etc/battery-charge-limit";
        options = [ "NOPASSWD" ];
      }
    ];
  }];

  # Power management
  services.power-profiles-daemon.enable = true;

  # Lid close: suspend on battery, ignore when docked (external power)
  services.logind.settings.Login.HandleLidSwitch = "suspend";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  # Firmware updates (fwupd)
  services.fwupd.enable = true;

  # Fingerprint reader (Framework)
  services.fprintd.enable = true;

  # System packages (core tools only — dev tools go in home-manager)
  environment.systemPackages = with pkgs; [
    curl
    dmidecode
    file
    git
    htop
    jq
    lsof
    tree
    unzip
    wget
  ];


  environment.localBinInPath = true;

  # Enable bolt for thunderbolt management
  services.hardware.bolt.enable = true;

  # Enable Gnome
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Dynamic linking support (needed for non-nix binaries and VS Code extensions)
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
  ];

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "darko" ];
  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://vicinae.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
  ];
  nix.optimise.automatic = true;

  system.stateVersion = "25.11";
}
