{ config, pkgs, lib, ... }:

{
  imports = [
  #  ../../home-manager/git.nix
  #  ../../home-manager/neovim.nix
  #  ../../home-manager/starship.nix
  #  ../../home-manager/tmux.nix
    ./shell.nix
  ];

  home.username = "darko";
  home.homeDirectory = "/home/darko";
  home.stateVersion = "25.11";

  nixpkgs.config.allowUnfree = true;

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  home.packages = with pkgs; [
    # Development environments
    devenv
    direnv
    python3

    # Search and navigation
    #fd
    #fuzzel
    #fzf
    #ripgrep
    #yazi

    # Build tools
    gcc

    # Kubernetes
    k9s
    kubectx
    kubectl

    # Containers
    podman
    podman-compose

    # GUI applications
    firefox
    ghostty
    slack
    pwvucontrol
    _1password-gui
    vscode.fhs
  ];

  home.file.".config/ghostty/config".source = ../../home-manager/dotfiles/ghostty/config;

  # SSH agent for loading keys
  services.ssh-agent.enable = true;
  home.sessionVariables.SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";

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
        eval "$(devenv direnv)"
      }
    '';
  };
}
