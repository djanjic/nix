---
name: add-package
description: Add a package to the right place in this nix config. Use when the user says "install X", "add package X", or "I want X on this machine". Picks between system-wide vs home-manager, and common vs machine-specific.
---

When the user wants to add a package, decide *where* it belongs before editing.

## Decision tree

1. **GUI app, dev tool, or user-level CLI?** → home-manager
   - Shared across machines → `home-manager/home.nix`
   - Laptop-only (Framework 13) → `laptop/home-manager/home.nix`
2. **System service, kernel module, hardware-related, or needs root?** → system
   - Shared across machines → `system/common/<topic>.nix` (create a new topic file if none fits)
   - Machine-specific → `system/framework/` or `system/development/`

## Steps

1. Read the appropriate file to confirm style (where the `home.packages` / `environment.systemPackages` list lives).
2. Add the package alphabetically into the existing list.
3. If it's a service (e.g. `services.foo.enable = true`), add it to a topical file under `system/common/` and make sure that file is imported by `common.nix`.
4. Tell the user to run `/rebuild` (or `./update.sh`) to apply.

## Notes

- Don't add `nixpkgs.config.allowUnfree = true` unless the package actually needs it; check if it's already set in the relevant scope.
- Prefer the channel that's already pinned (see `update.sh` — currently `nixos-25.11`). Don't introduce flakes unless asked.
