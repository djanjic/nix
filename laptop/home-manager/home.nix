{ config, pkgs, lib, ... }:

{
  imports = [
    ../../home-manager/claude.nix
    ../../home-manager/vscode.nix
    ../../home-manager/firefox.nix
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
    gh
    devcontainer
    gnumake
    xclip

    # Build tools
    gcc

    # Kubernetes
    k9s
    kubectx
    kubectl
    kubelogin-oidc
    vcluster

    # Containers
    docker
    docker-compose

    # Gnome
    gnomeExtensions.appindicator

    # System monitor
    gnomeExtensions.astra-monitor
    amdgpu_top  # AMD GPU stats backend for astra-monitor
    lm_sensors  # `sensors` CLI for CPU/GPU temps and fan RPM

    # GUI applications
    ghostty
    slack
    pwvucontrol
    _1password-gui
    zoom-us
    steam
    dbeaver-bin
    telegram-desktop
    joplin-desktop
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
        "monitor@astraext.github.io"
      ];
      favorite-apps = [
        "firefox.desktop"
        "slack.desktop"
        "codium.desktop"
        "com.mitchellh.ghostty.desktop"
        "dbeaver.desktop"
        "joplin.desktop"
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
      # Inspect current settings: dconf dump /org/gnome/shell/extensions/astra-monitor/
      processor-header-show = true;
      memory-header-show = true;
     # gpu-header-show = true;
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
