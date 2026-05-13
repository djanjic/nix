{ config, pkgs, lib, ... }:

let
  statuslineScript = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = with pkgs; [ jq git coreutils ];
    text = ''
      input=$(cat)
      model=$(jq -r '.model.display_name // "?"' <<< "$input")
      ctx_pct=$(jq -r '(.context_window.used_percentage // 0) | floor' <<< "$input")
      cwd=$(jq -r '.workspace.current_dir // ""' <<< "$input")
      short_cwd="''${cwd/#$HOME/\~}"
      branch=$(git -C "$cwd" branch --show-current 2>/dev/null || true)

      RESET=$'\033[0m'
      BOLD=$'\033[1m'
      DIM=$'\033[2m'
      CYAN=$'\033[36m'
      BLUE=$'\033[34m'
      GREEN=$'\033[32m'
      YELLOW=$'\033[33m'
      RED=$'\033[31m'

      if (( ctx_pct >= 80 )); then
        ctx_color=$RED
      elif (( ctx_pct >= 50 )); then
        ctx_color=$YELLOW
      else
        ctx_color=$GREEN
      fi

      bar_width=10
      filled=$(( ctx_pct * bar_width / 100 ))
      (( filled > bar_width )) && filled=$bar_width
      empty=$(( bar_width - filled ))

      bar="$ctx_color"
      for ((i=0; i<filled; i++)); do bar+="█"; done
      bar+="$DIM"
      for ((i=0; i<empty; i++)); do bar+="░"; done
      bar+="$RESET"

      sep="$DIM·$RESET"
      out="$BOLD$CYAN$model$RESET $sep $bar $sep $BLUE$short_cwd$RESET"
      if [ -n "$branch" ]; then
        out="$out $DIM($branch)$RESET"
      fi
      printf '%s\n' "$out"
    '';
  };
in
{
  home.packages = [ pkgs.claude-code ];

  home.file.".claude/settings.json" = {
    force = true;
    text = builtins.toJSON {
      model = "claude-opus-4-7";
      statusLine = {
        type = "command";
        command = "${statuslineScript}/bin/claude-statusline";
      };
    };
  };

  home.activation.registerClaudeMcpServers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -x ${pkgs.claude-code}/bin/claude ]; then
      ${pkgs.claude-code}/bin/claude mcp remove --scope user gopls >/dev/null 2>&1 || true
      ${pkgs.claude-code}/bin/claude mcp add --scope user gopls -- gopls mcp >/dev/null
    fi
  '';
}
