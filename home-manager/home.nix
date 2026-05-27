{ config, pkgs, ... }:

{
  imports = [
    ./claude.nix
    ./git.nix
    ./neovim.nix
    ./starship.nix
    ./tmux.nix
  ];

  home.username = "darko;
  home.homeDirectory = "/home/darko";
  home.stateVersion = "25.11";

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Development environments
    devcontainer
    devenv
    direnv
    python3
    gh

    # Search and navigation
    fd
    fzf
    ripgrep
    yazi

    # Build tools
    gcc
    nodejs

    # Yubikey
    yubikey-manager

    # General tools
    file
    jq
    lazygit
    lsof
    mr
    tree
    unzip
    zoxide
  ];

  home.file.".claude/skills/humanizer".source = humanizer;
  home.file.".claude/settings.json" = {
    source = ./dotfiles/claude/settings.json;
    force = true;
  };
  home.file.".claude/hooks/block-sensitive-reads.sh" = {
    source = ./dotfiles/claude/hooks/block-sensitive-reads.sh;
    executable = true;
  };
  home.file.".config/git/light-config".source = ./dotfiles/git/light-config;
  home.file.".config/git/light-ignore".source = ./dotfiles/git/light-ignore;
  home.file.".config/git/git-signing-key.sh" = {
    source = ./dotfiles/git/git-signing-key.sh;
    executable = true;
  };
  home.file.".mrconfig".source = ./dotfiles/myrepos/mrconfig;
  home.file.".mrtrust".source = ./dotfiles/myrepos/mrtrust;

  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    stdlib = ''
      use_devenv() {
        eval "$(devenv direnvrc)"
        use_devenv "$@"
      }
    '';
  };

}
