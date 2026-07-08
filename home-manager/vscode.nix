{ config, pkgs, lib, ... }:

let
  nix-vscode-extensions = import (builtins.fetchTarball {
    url = "https://github.com/nix-community/nix-vscode-extensions/archive/464e8cf8572089a5b84ade70726da59b7e1c0c6f.tar.gz";
    sha256 = "12iah31dm1wwy82463p1bvsns9sayhjb5rzwlrh12kzjgj2n1i7w";
  });
  marketplace = nix-vscode-extensions.extensions.${pkgs.stdenv.hostPlatform.system}.vscode-marketplace;
  allowUnfree = ext: ext.overrideAttrs (old: {
    meta = old.meta // { license = old.meta.license // { free = true; }; };
  });
in
{
  programs.vscodium = {
    enable = true;
    package = pkgs.vscodium-fhs;
    profiles.default = {
      userSettings = {
        "editor.formatOnSave" = true;
        "files.autoSave" = "afterDelay";
        "claudeCode.preferredLocation" = "sidebar";
        "chat.commandCenter.enabled" = false;
        "editor.minimap.enabled" = false;
        "workbench.colorTheme" = "Dark Modern";
        "workbench.startupEditor" = "none";
        "workbench.welcomePage.walkthroughs.openOnInstall" = false;
      };
      extensions = [
        marketplace.golang.go
        marketplace.datakurre.devenv
        marketplace.mkhl.direnv
        (allowUnfree marketplace.ms-vscode-remote.remote-containers)
        marketplace.openfga.openfga-vscode
      ];
    };
  };
}
