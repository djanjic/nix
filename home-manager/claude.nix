{ config, pkgs, lib, ... }:

let
  claude-code = (builtins.getFlake "github:sadjow/claude-code-nix").packages.${pkgs.system}.default;

  statuslineScript = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = with pkgs; [ jq git coreutils gnugrep gnused gawk ];
    text = ''
      input=$(cat)

      RESET=$'\033[0m'; BOLD=$'\033[1m'; DIM=$'\033[2m'
      CYAN=$'\033[36m'; BLUE=$'\033[34m'; GREEN=$'\033[32m'
      YELLOW=$'\033[33m'; RED=$'\033[31m'; MAGENTA=$'\033[35m'

      make_bar() {
        local pct=$1 width=''${2:-10}
        local color=$GREEN
        if (( pct >= 80 )); then color=$RED
        elif (( pct >= 50 )); then color=$YELLOW
        fi
        local filled=$(( pct * width / 100 ))
        (( filled > width )) && filled=$width
        local empty=$(( width - filled ))
        local b="$color" i
        for ((i=0; i<filled; i++)); do b+="█"; done
        b+="$DIM"
        for ((i=0; i<empty; i++)); do b+="░"; done
        b+="$RESET"
        printf '%s' "$b"
      }

      truncate_str() {
        local s=$1 max=''${2:-30}
        if (( ''${#s} > max )); then
          printf '%s' "''${s:0:max-1}…"
        else
          printf '%s' "$s"
        fi
      }

      # Header
      model_display=$(jq -r '.model.display_name // .model.id // "?"' <<< "$input")
      short_model=$(sed -E 's/^Claude *//; s/ .*//' <<< "$model_display")

      cwd=$(jq -r '.workspace.current_dir // .cwd // ""' <<< "$input")
      project=$(basename "$cwd")
      transcript_path=$(jq -r '.transcript_path // ""' <<< "$input")

      branch=""; dirty=""
      if [ -n "$cwd" ]; then
        branch=$(git -C "$cwd" branch --show-current 2>/dev/null || true)
        if [ -n "$branch" ]; then
          if [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null)" ]; then
            dirty="*"
          fi
        fi
      fi

      # Context
      ctx_pct=$(jq -r '(.context_window.used_percentage // 0) | floor' <<< "$input")

      # Usage (5h window)
      usage_pct=$(jq -r '(.rate_limits.five_hour.used_percentage // 0) | floor' <<< "$input")
      resets_at=$(jq -r '.rate_limits.five_hour.resets_at // 0' <<< "$input")
      now=$(date +%s)
      if (( resets_at > 10000000000 )); then resets_at=$(( resets_at / 1000 )); fi
      window_secs=$(( 5 * 3600 ))
      if (( resets_at > now )); then
        elapsed=$(( window_secs - (resets_at - now) ))
        (( elapsed < 0 )) && elapsed=0
      else
        elapsed=0
      fi
      eh=$(( elapsed / 3600 )); em=$(( (elapsed % 3600) / 60 ))
      if (( eh > 0 )); then elapsed_fmt="''${eh}h ''${em}m"; else elapsed_fmt="''${em}m"; fi

      ctx_bar=$(make_bar "$ctx_pct" 10)
      usage_bar=$(make_bar "$usage_pct" 10)
      sep="$DIM│$RESET"

      line1="$BOLD''${CYAN}[$short_model]$RESET $sep $BOLD$project$RESET"
      if [ -n "$branch" ]; then
        line1="$line1 ''${MAGENTA}git:($branch$dirty)$RESET"
      fi

      line2="''${BOLD}Context$RESET $ctx_bar ''${ctx_pct}% $sep ''${BOLD}Usage$RESET $usage_bar ''${usage_pct}% $DIM($elapsed_fmt / 5h)$RESET"

      line3=""; line4=""; line5=""

      if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
        recent=$(tail -n 500 "$transcript_path" 2>/dev/null || true)

        # Tool activity
        tools_json=$(jq -c 'select(.type == "assistant") | .message.content[]? | select(.type == "tool_use") | {name: .name, target: (.input.file_path // .input.pattern // .input.command // .input.subagent_type // "")}' <<< "$recent" 2>/dev/null || true)

        if [ -n "$tools_json" ]; then
          last_line=$(printf '%s' "$tools_json" | tail -n 1)
          last_name=$(jq -r '.name' <<< "$last_line")
          last_target=$(jq -r '.target' <<< "$last_line")
          if [ -n "$last_target" ] && [ "$last_target" != "null" ]; then
            case "$last_target" in
              /*) last_target=$(basename "$last_target") ;;
            esac
            last_target=$(truncate_str "$last_target" 30)
          else
            last_target=""
          fi

          activity="''${YELLOW}◐$RESET $BOLD$last_name$RESET"
          [ -n "$last_target" ] && activity+=": $last_target"

          counts=$(printf '%s' "$tools_json" | head -n -1 | jq -r '.name' 2>/dev/null | sort | uniq -c | sort -rn | head -n 3 || true)
          while IFS= read -r ct; do
            [ -z "$ct" ] && continue
            c=$(awk '{print $1}' <<< "$ct")
            n=$(awk '{print $2}' <<< "$ct")
            activity+=" $DIM|$RESET ''${GREEN}✓$RESET $n ''${DIM}×$c$RESET"
          done <<< "$counts"

          line3="$activity"
        fi

        # Agent: last Task tool_use
        last_task=$(jq -c 'select(.type == "assistant") | .message.content[]? | select(.type == "tool_use" and .name == "Task")' <<< "$recent" 2>/dev/null | tail -n 1 || true)
        if [ -n "$last_task" ] && [ "$last_task" != "null" ]; then
          t_type=$(jq -r '.input.subagent_type // "agent"' <<< "$last_task")
          t_model=$(jq -r '.input.model // ""' <<< "$last_task")
          t_desc=$(jq -r '.input.description // ""' <<< "$last_task")
          line4="''${YELLOW}◐$RESET $BOLD$t_type$RESET"
          [ -n "$t_model" ] && [ "$t_model" != "null" ] && line4+=" ''${DIM}[$t_model]$RESET"
          [ -n "$t_desc" ] && [ "$t_desc" != "null" ] && line4+=": $(truncate_str "$t_desc" 50)"
        fi

        # Todo: latest TodoWrite
        latest_todo=$(tac "$transcript_path" 2>/dev/null | grep -m 1 '"name":"TodoWrite"' || true)
        if [ -n "$latest_todo" ]; then
          todos=$(jq -c '[.message.content[]? | select(.type == "tool_use" and .name == "TodoWrite")] | last | .input.todos // []' <<< "$latest_todo" 2>/dev/null || echo "[]")
          if [ "$todos" != "[]" ] && [ "$todos" != "null" ]; then
            total=$(jq 'length' <<< "$todos")
            complete=$(jq '[.[] | select(.status == "completed")] | length' <<< "$todos")
            current=$(jq -r '([.[] | select(.status == "in_progress")] + [.[] | select(.status == "pending")])[0].content // ""' <<< "$todos")
            if [ -n "$current" ] && [ "$current" != "null" ]; then
              line5="''${BLUE}▸$RESET $(truncate_str "$current" 50) $DIM($complete/$total)$RESET"
            fi
          fi
        fi
      fi

      printf '%s\n%s\n' "$line1" "$line2"
      [ -n "$line3" ] && printf '%s\n' "$line3"
      [ -n "$line4" ] && printf '%s\n' "$line4"
      [ -n "$line5" ] && printf '%s\n' "$line5"
      true
    '';
  };
  managedSettings = pkgs.writeText "claude-settings-managed.json" (builtins.toJSON {
    statusLine = {
      type = "command";
      command = "${statuslineScript}/bin/claude-statusline";
    };
  });
in
{
  home.packages = [ claude-code ];

  # settings.json is left mutable so /effort, /config etc. can write to it;
  # the keys below are merged in on every activation and win over local values.
  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    settings="$HOME/.claude/settings.json"
    managed="${managedSettings}"

    $DRY_RUN_CMD mkdir -p "$HOME/.claude"

    if [ -L "$settings" ]; then
      $DRY_RUN_CMD rm -f "$settings"
    fi

    current=$(cat "$settings" 2>/dev/null || true)
    if ! printf '%s' "$current" | ${pkgs.jq}/bin/jq -e 'type == "object"' >/dev/null 2>&1; then
      if [ -n "$current" ]; then
        $DRY_RUN_CMD cp "$settings" "$settings.bak"
        echo "claude: settings.json was not valid JSON, backed up to $settings.bak"
      fi
      current='{}'
    fi

    merged=$(mktemp)
    printf '%s' "$current" | ${pkgs.jq}/bin/jq --slurpfile m "$managed" '. * $m[0]' > "$merged"
    $DRY_RUN_CMD cp "$merged" "$settings"
    rm -f "$merged"
  '';

  home.activation.registerClaudeMcpServers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -x ${claude-code}/bin/claude ]; then
      ${claude-code}/bin/claude mcp remove --scope user gopls >/dev/null 2>&1 || true
      ${claude-code}/bin/claude mcp add --scope user gopls -- gopls mcp >/dev/null
    fi
  '';
}
