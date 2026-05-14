{ config, pkgs, lib, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium-fhs;
    profiles.default = {
      userSettings = {
        "editor.formatOnSave" = true;
        "files.autoSave" = "afterDelay";
        "claudeCode.preferredLocation" = "sidebar";
        "chat.commandCenter.enabled" = false;
        "editor.minimap.enabled" = false;
        "workbench.colorTheme" = "Default Dark Modern";
        "workbench.startupEditor" = "none";
        "workbench.welcomePage.walkthroughs.openOnInstall" = false;
      };
      extensions = with pkgs.vscode-extensions; [
        anthropic.claude-code
        golang.go
        mkhl.direnv
      ];
    };
  };
}
