{ config, pkgs, lib, ... }:

{
  imports = [
  #  ../../home-manager/git.nix
  #  ../../home-manager/neovim.nix
  #  ../../home-manager/starship.nix
  #  ../../home-manager/tmux.nix
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
    docker
    docker-compose

    # Gnome
    gnomeExtensions.appindicator
    gnomeExtensions.astra-monitor

    # GUI applications
    firefox
    ghostty
    slack
    pwvucontrol
    _1password-gui
    vscode.fhs
    zoom-us
    steam
    dbeaver-bin
  ];

  home.file.".config/ghostty/config".source = ../../home-manager/dotfiles/ghostty/config;

  # SSH agent for loading keys
  services.ssh-agent.enable = true;
  home.sessionVariables.SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";

  programs.home-manager.enable = true;

  dconf.enable = true;
  dconf.settings = {
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "astra-monitor@AstraExt"
      ];
      favorite-apps = [
        "firefox.desktop"
        "slack.desktop"
        "code.desktop"
        "com.mitchellh.ghostty.desktop"
        "dbeaver.desktop"
      ];
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = false;
      tap-to-click = true;
    };
    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = false;
    };
    "org/gnome/desktop/interface".show-battery-percentage = true;
    "org/gnome/mutter" = {
        experimental-features = [
          "scale-monitor-framebuffer" # Enables fractional scaling (125% 150% 175%)
          "xwayland-native-scaling" # Scales Xwayland applications to look crisp on HiDPI screens
          "autoclose-xwayland" # automatically terminates Xwayland if all relevant X11 clients are gone
        ];
      };
    "org/gnome/shell/extensions/astra-monitor" = {
      # Example: Customize displayed items (dconf dump /org/gnome/shell/extensions/astra-monitor/)
      show-cpu = true;
      show-ram = true;
      show-gpu = false;
    };
  };

  programs.starship = {
    enable = true;
    # Configuration written to ~/.config/starship.toml
    settings = {
      # add_newline = false;

      # character = {
      #   success_symbol = "[➜](bold green)";
      #   error_symbol = "[➜](bold red)";
      # };

      # package.disabled = true;
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
