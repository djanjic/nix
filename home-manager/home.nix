{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; overlays = []; };
in
{
  imports = [
    ./git.nix
    ./neovim.nix
    ./starship.nix
    ./tmux.nix
  ];

  home.username = "darlp";
  home.homeDirectory = "/home/darko";
  home.stateVersion = "25.11";

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Development environments
    devenv
    direnv
    python3

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
  ] ++ [
    (unstable.claude-code.overrideAttrs (old: rec {
      version = "2.1.90";
      src = pkgs.fetchurl {
        url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
        hash = "sha256-PLACEHOLDER";
      };
      npmDepsHash = "sha256-PLACEHOLDER2";
    }))
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

  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "code.desktop"
        "com.mitchellh.ghostty.desktop"
      ];
    };
  };


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
