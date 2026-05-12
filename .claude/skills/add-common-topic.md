---
name: add-common-topic
description: Add a new topic module under system/common/ and wire it into common.nix imports. Use when the user wants a new shared system-level concern (e.g. "add a vpn module", "split out the firewall config", "new common.nix topic for X").
---

Add a new topic file under `system/common/` and register it in `system/common/common.nix`.

## Steps

1. Create `system/common/<topic>.nix` using the standard module shape:

   ```nix
   { config, pkgs, ... }:

   {
     # <topic>
     # ...config here...
   }
   ```

   Match the style of existing topic files like `system/common/docker.nix` — short header comment, then the options.

2. Add `./<topic>.nix` to the `imports` list in `system/common/common.nix`. Keep it in the same loose grouping as neighbors (the list is not strictly alphabetical — `darko.nix` is first, the rest are roughly grouped by theme).

3. If the topic should be opt-in per machine, leave it commented out in `common.nix` (like `#./tlp.nix`) and let the user uncomment when ready.

4. Tell the user to run `/rebuild` to apply.

## Notes

- Don't put machine-specific things here — those go under `system/framework/` or `system/development/`.
- Don't dump everything into `common.nix` itself; the point of this layout is one concern per file.
- If the topic adds packages, prefer `environment.systemPackages = with pkgs; [ ... ]` inside the topic file rather than pushing them up into a global list.
