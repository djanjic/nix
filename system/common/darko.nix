{ config, pkgs, ... }:

{
  #users.users.root.openssh.authorizedKeys.keys = [
  #  "<key>"
  #];

  users.users.darko = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager"];
    #openssh.authorizedKeys.keys = [
    #  "<key>"
    #];
  };

  #security.sudo.wheelNeedsPassword = false;
}
