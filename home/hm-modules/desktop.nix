{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.desktop;
in
{
  options.desktop = {
    enable = lib.mkEnableOption "desktop computer";
    niri.enable = lib.mkEnableOption "niri wm";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      xdg.configFile."base16-theme.json" = {
        text = builtins.readFile config.stylix.generated.fileTree."stylix/palette.json".source;
      };

      services.gpg-agent = {
        enable = true;
        pinentry.package = pkgs.pinentry-gnome3;
      };

      programs.wezterm = {
        enable = true;
        settings = {
          hide_tab_bar_if_only_one_tab = true;
          automatically_reload_config = true;
          selection_word_boundary = " \t\n{}[]()\"'`«»";
        };
      };

      # programs.ninjabrain-bot = {
      #   enable = true;
      #   stylix = false;
      #   force = true;
      #   settings = {
      #     hotkey_decrement.key = 57419; # "right"
      #     hotkey_increment.key = 57421; # "left"
      #
      #     hotkey_lock.key = 23; # "i"
      #     hotkey_reset = {
      #       key = 19; # "r"
      #       modifiers = [ "ALT_L" ];
      #     };
      #
      #     view = "detailed";
      #     all_advancements = false;
      #     mc_version = "pre_119";
      #     sensitivity = 0.02291165;
      #
      #     size = "medium";
      #
      #     default_boat_type = "green";
      #     alt_clipboard_reader = false;
      #     angle_adjustment_display_type = "increments";
      #     angle_adjustment_type = "tall";
      #     auto_reset = false;
      #     color_negative_coords = false;
      #     direction_help_enabled = true;
      #     show_angle_errors = true;
      #     show_angle_updates = true;
      #     sigma_boat = 0.0007;
      #     stronghold_display_type = "fourfour";
      #     use_adv_statistics = true;
      #     use_precise_angle = true;
      #
      #     enable_http_server = true;
      #   };
      # };

      xdg.configFile = {
        "waywall/init.lua".text = ''
          local paths = {
              bg = "${
                pkgs.runCommand "convert.png"
                  {
                    nativeBuildInputs = [ pkgs.imagemagick ];
                  }
                  ''
                    convert ${config.stylix.image} out.png
                    mv out.png $out
                  ''
              }",
              java = "${lib.getExe' pkgs.openjdk25 "java"}",
              ninb = "${
                pkgs.fetchurl {
                  url = "https://github.com/Ninjabrain1/Ninjabrain-Bot/releases/download/1.5.1/Ninjabrain-Bot-1.5.1.jar";
                  hash = "sha256-Rxu9A2EiTr69fLBUImRv+RLC2LmosawIDyDPIaRcrdw=";
                }
              }",
              overlay = "${./overlay.png}",
          }

          ${builtins.readFile ./waywall.lua}
        '';

        "xkb/symbols/mc".text = ''
          default partial alphanumeric_keys
          xkb_symbols "basic" {
              include "us(basic)"

              name[Group1] = "Minecraft";

              key <AD01> { [ i, I ] }; // q > i
              key <AD03> { [ o, O ] }; // e > o
              key <AC02> { [ e, E ] }; // s > e
              key <AC03> { [ b, b ] }; // d > b
              key <AC04> { [ k, K ] }; // f > k
              key <AC05> { [ d, D ] }; // g > d
              key <AB01> { [ p, P ] }; // z > p

              key <AD08> { [ q, Q ] }; // q < i
              key <AD09> { [ e, E ] }; // e < o
              // key <AC02> { [ e, E ] }; // s > e
              key <AB05> { [ d, D ] }; // d < b
              key <AC08> { [ f, F ] }; // f < k
              // key <AC05> { [ d, D ] }; // g > d
              key <AD10> { [ z, Z ] }; // z < p
              // key <AB01> { [ p, P ] }; // z > p
          };
        '';
      };
    })

    (lib.mkIf cfg.niri.enable {
      home.pointerCursor = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
        size = 24;
        x11 = {
          enable = true;
          defaultCursor = "Adwaita";
        };
      };
      programs.niri.settings = {
        spawn-at-startup = [
          {
            argv = [
              "noctalia"
            ];
          }
          { argv = [ "google-chrome-stable" ]; }
          { argv = [ "equibop" ]; }
        ];

        outputs = {
          "DP-2" = {
            mode = {
              width = 2560;
              height = 1440;
              # refresh = 164.999;
              refresh = 239.998;
            };
            position = {
              x = 1080;
              y = 500;
            };
            variable-refresh-rate = true;
          };

          "HDMI-A-1" = {
            mode = {
              width = 1920;
              height = 1080;
              refresh = 100.0;
            };
            position = {
              x = 0;
              y = 0;
            };
          };
        };

        input.mouse.accel-profile = "flat";

        xwayland-satellite = {
          enable = true;
          path = lib.getExe pkgs.xwayland-satellite;
        };

        binds =
          with config.lib.niri.actions;
          {
            # Core Noctalia binds
            "Mod+Space".action = spawn "noctalia" "msg" "panel-toggle" "launcher";

            # Audio & Brightness
            "XF86AudioRaiseVolume".action = spawn "noctalia" "msg" "volume-up";
            "XF86AudioLowerVolume".action = spawn "noctalia" "msg" "volume-down";
            "XF86AudioMute".action = spawn "noctalia" "msg" "volume-mute";
            "XF86MonBrightnessUp".action = spawn "noctalia" "msg" "brightness-up";
            "XF86MonBrightnessDown".action = spawn "noctalia" "msg" "brightness-down";

            # "Mod+Shift+C".action = spawn "noctalia" "msg" "clipboard" "emoji";

            "Mod+Shift+Slash".action = show-hotkey-overlay;
            "Mod+Return".action = spawn "wezterm";
            "Mod+O" = {
              action = toggle-overview;
              repeat = false;
            };
            "Mod+Shift+Q".action = close-window;
            "Mod+Shift+E".action = quit;

            "Mod+H".action = focus-column-left;
            "Mod+J".action = focus-window-down;
            "Mod+K".action = focus-window-up;
            "Mod+L".action = focus-column-right;

            "Mod+Ctrl+H".action = move-column-left;
            "Mod+Ctrl+J".action = move-window-down;
            "Mod+Ctrl+K".action = move-window-up;
            "Mod+Ctrl+L".action = move-column-right;

            "Mod+F".action = maximize-column;
            "Mod+Shift+F".action = fullscreen-window;

            "Mod+V".action = toggle-window-floating;

            "Mod+W".action = toggle-column-tabbed-display;
            "Mod+Shift+S".action.screenshot = [ ];
            "Mod+Ctrl+Shift+S".action.screenshot-window = [ ];
          }
          // (builtins.listToAttrs (
            lib.flatten (
              builtins.map (x: [
                (lib.nameValuePair "Mod+${builtins.toString x}" {
                  action = config.lib.niri.actions.focus-workspace x;
                })
                # (lib.nameValuePair "Mod+Ctrl+${builtins.toString x}" {
                #   action = config.lib.niri.actions.move-column-to-workspace x;
                # })
              ]) (lib.range 1 9)
            )
          ));

        workspaces = {
          "web" = {
            open-on-output = "DP-3";
            name = "1";
          };
          "games" = {
            open-on-output = "DP-3";
            name = "2";
          };
          "chat" = {
            open-on-output = "HDMI-A-1";
            name = "3";
          };
          "music" = {
            open-on-output = "HDMI-A-1";
            name = "4";
          };
        };

        window-rules = [
          {
            geometry-corner-radius =
              let
                value = 8.0;
              in
              {
                bottom-left = value;
                bottom-right = value;
                top-left = value;
                top-right = value;
              };
            clip-to-geometry = true;
            # https://github.com/YaLTeR/niri/issues/2346
            # amd problem...?
            draw-border-with-background = false;
          }
          {
            matches = [ { app-id = "equibop"; } ];
            open-on-workspace = "chat";
          }
          {
            matches = [ { app-id = "google-chrome"; } ];
            open-on-workspace = "web";
          }
          {
            matches = [ { app-id = "feishin"; } ];
            open-on-workspace = "music";
          }
        ];

        layer-rules = [
          {
            matches = [
              { namespace = "^noctalia-backdrop*"; }
            ];
            place-within-backdrop = true;
          }
        ];

        switch-events.lid-close.action.spawn = [
          "noctalia"
          "msg"
          "session"
          "lock-and-suspend"
        ];

        layout = {
          gaps = 0;
          background-color = "transparent";
          border.width = 2;
          tab-indicator = {
            place-within-column = true;
            position = "top";
          };
        };

        # https://docs.noctalia.dev/getting-started/compositor-settings/niri/
        debug.honor-xdg-activation-with-invalid-serial = [ ];
      };

      stylix.targets.noctalia.enable = true;

      programs.noctalia = {
        enable = true;
        settings = {
          shell = {
            time_format = "{:%-I:%M %p}";
          };
          bar.default.position = "left";
        };
      };
    })
  ];
}
