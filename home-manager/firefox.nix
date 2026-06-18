{ config, pkgs, lib, ... }:

{
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;  # force native Wayland
    MOZ_USE_XINPUT2 = 1;     # touch gestures / smooth scrolling
  };

  programs.firefox = {
    enable = true;
    configPath = ".config/mozilla/firefox";
    profiles.default = {
      id = 0;
      settings = {
        "ui.context_menus.after_mouseup" = true;

        # Hardware video decoding (VA-API)
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;
      };
    };
  };
}
