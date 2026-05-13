{ config, pkgs, lib, ... }:

{
  home.packages = [ pkgs.claude-code ];

  home.activation.registerClaudeMcpServers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -x ${pkgs.claude-code}/bin/claude ]; then
      ${pkgs.claude-code}/bin/claude mcp remove --scope user gopls >/dev/null 2>&1 || true
      ${pkgs.claude-code}/bin/claude mcp add --scope user gopls -- gopls mcp >/dev/null
    fi
  '';
}
