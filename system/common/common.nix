{ config, pkgs, ... }:

{
  imports =
    [
      ./darko.nix
      ./bluetooth.nix
      ./locale.nix
      ./podman.nix
      ./printing.nix
      #./network.nix
      ./sound.nix
      ./tlp.nix
      #./zsh.nix
    ];
}
