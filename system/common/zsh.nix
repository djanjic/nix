{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    histSize = 10000;
    setOptions = [ "HIST_IGNORE_DUPS" "SHARE_HISTORY" "AUTO_CD" ];
    promptInit = "";  # Disable default prompt (starship is set up via home-manager)
    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -lah --color=auto";
      grep = "grep --color=auto";
    };
    interactiveShellInit = ''
      # Suppress zsh new-user wizard (all config is managed by NixOS + home-manager)
      zsh-newuser-install() { :; }

      # Source home-manager session variables (SSH_AUTH_SOCK, etc.)
      [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ] && . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

      export PATH="/usr/local/bin:$PATH"

      # Tab accepts autosuggestion if one is visible, otherwise does normal completion
      _accept_or_complete() {
        if [[ -n "$POSTDISPLAY" ]]; then
          zle autosuggest-accept
        else
          zle expand-or-complete
        fi
      }
      zle -N _accept_or_complete
      bindkey '\t' _accept_or_complete

      eval "$(starship init zsh)"

      # Tmux session picker (skip if already in tmux or inside an IDE terminal)
      if [[ -z "$TMUX" && -z "$VSCODE_INJECTION" ]]; then
        echo "1) Attach to 'main' session"
        echo "2) No tmux"
        echo "3) New named session"
        printf "\nChoice [1]: "
        read -r choice
        case "''${choice:-1}" in
          1) tmux new-session -A -s main ;;
          2) ;; # do nothing
          3) printf "Session name: "; read -r name
             if [[ -n "$name" ]]; then
               tmux new-session -s "$name"
             fi ;;
          *) echo "Invalid choice" ;;
        esac
      fi
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
