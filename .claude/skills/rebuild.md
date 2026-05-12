---
name: rebuild
description: Run the repo's update.sh to rebuild NixOS + home-manager. Use when the user says "rebuild", "apply config", "switch", or after editing files under system/ or home-manager/.
---

Run `./update.sh` from the repo root to apply the current config. It:

1. Updates nix channels
2. Detects the machine (Framework 13 laptop vs. development VM) via `dmidecode`
3. Symlinks the right `system/<machine>` dir to `/etc/nixos` and home-manager dir to `~/.config/home-manager`
4. Runs `nixos-rebuild switch` (needs sudo)
5. Runs `home-manager switch`
6. Prunes old generations and garbage-collects

Notes:
- The script uses `set -euf` — first failure aborts. Read the failing step's output rather than re-running blindly.
- Always confirm with the user before running — this modifies the live system.
