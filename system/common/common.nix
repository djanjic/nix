{ config, pkgs, ... }:

{
  imports =
    [
      ./darko.nix
      ./bluetooth.nix
      ./locale.nix
      ./docker.nix
      ./printing.nix
      ./sound.nix
      #./tlp.nix
      ./zsh.nix
    ];
}
