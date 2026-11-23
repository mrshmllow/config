{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.desktop;
in
{
  options.desktop = {
    enable = lib.mkEnableOption "desktop computer";
    niri.enable = lib.mkEnableOption "niri wm";
    mcsr.enable = lib.mkEnableOption "mcsr";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      # temporary: broken
      stylix.targets.wayprompt.enable = false;

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
    })

    (lib.mkIf cfg.mcsr.enable {
      nixcraft = {
        enable = true;

        client = {
          shared = {
            enableExternalAssets = true;
            account = {
              uuid = "dd4edde3-f0c7-4e27-82df-9c374548f2b9";
              username = "tenatq";
              offline = false;
            };
          };

          instances.ranked = {
            version = "1.16.1";
            desktopEntry.enable = true;
            waywall.enable = true;
            fabricLoader.enable = true;
            mods =
              let
                mkLegalAdv =
                  {
                    name,
                    hash,
                    version ? "1.16.1",
                    ppart ? builtins.head (builtins.split "-" name),
                  }:
                  pkgs.fetchurl {
                    inherit hash;
                    url = "https://github.com/Minecraft-Java-Edition-Speedrunning/legal-mods/raw/2ba63fc475270404e4a1c1f910f22bdc9bc14186/legal-mods/${ppart}/${version}/${name}";
                  };

                mkLegal = name: hash: mkLegalAdv { inherit name hash; };
              in
              [
                (mkLegal "antigone-1.16.1-2.0.0.jar" "sha256-suUFhZYEhhjoZN2WRfrRJ4m1z31NY19Dfx/8B99YTPY=")
                (mkLegal "antiresourcereload-5.2.0+1.16.1.jar" "sha256-0UEFlblhZHmcJKCmoa+HHKiHmHmUzJSMxd2rYeGWn8U=")
                (mkLegalAdv {
                  name = "krypton-1.16.1-backport-0.1.3-SNAPSHOT+2021-02-20.jar";
                  hash = "sha256-ZHqIZXc0COUyQq/rr10YuEEmFsHCYPH/XdzxwMv1DIc=";
                  version = "1.15-1.16.1";
                })
                (pkgs.fetchurl {
                  url = "https://cdn.modrinth.com/data/hvFnDODi/versions/0.1.2/lazydfu-0.1.2.jar";
                  hash = "sha256-546xSS4gvNjJmNQULdQ3wlFzk8XQL1giBK2KODQedeg=";
                })
                (mkLegal "lazystronghold-1.1.4+1.16.1.jar" "sha256-wsSLGXqVBg9T9NCEFAnja3pfAIuR2tA/XjvMQIdHeQs=")
                (mkLegal "lithium-1.0+backport-0.6.7+1.16.1.jar" "sha256-FwjezXLDKWRrNZ95UiT4iNGKnePJjfQHnDGZxy3p+8M=")
                (pkgs.fetchurl {
                  url = "https://cdn.modrinth.com/data/I9W1u5Ac/versions/Uppa2nGO/mcsrranked-6.0.12.jar";
                  hash = "sha256-88U8h4jTG7hlugNPoKIawHWB07365RsevulblCatrE0=";
                })
                (mkLegal "sodium-2.5.1+1.16.1.jar" "sha256-ChV1fDZ07Pdn2FwJ3mPxr69zDe1+ozfvyw+w90dRvAY=")
                (mkLegalAdv {
                  name = "standardsettings-2.3+1.16-1.16.1.jar";
                  hash = "sha256-KVoWPvh9yLxOWiqz9b1X4snnKYBpiTrb9XW5++Fno8w=";
                  version = "1.16-1.16.1";
                })
                (mkLegalAdv {
                  name = "starlight-1.3.0+1.16.x-backport-1.1.3.jar";
                  hash = "sha256-hJI3iu/gKRemWegrJMRHq4BfCMp5zVhLw+iE/wiGRWg=";
                  version = "1.16-1.16.5";
                })
                (mkLegalAdv {
                  name = "state-output-1.2.3+1.16-1.18.1.jar";
                  hash = "sha256-Bnfqjx0xEFmOLMQ1AnL7X1Mi10y6KP+JjGeEjs3x8cU=";
                  ppart = "state-output";
                  version = "1.16-1.18.1";
                })
                (mkLegalAdv {
                  name = "voyager-1.0.1.jar";
                  hash = "sha256-n2Si00RSdwoiXyhNGUiuqK8Fhmxbp6T8O4g2mXtN6EQ=";
                  version = "1.14-1.16.5";
                })
              ];
            java = {
              package = inputs.mcsr-nixos.packages.${pkgs.stdenv.hostPlatform.system}.graalvm-21;
              minMemory = 512;
              maxMemory = 4096;
              extraArguments = [ ];
            };

            saves = {
              "practice" = pkgs.fetchzip {
                url = "https://github.com/Dibedy/The-MCSR-Practice-Map/releases/download/latest/MCSR.Practice.v2.0.0.zip";
                stripRoot = false;
                hash = "sha256-zyCmVAypjspbbvaraaYQtckmpACn82TjZakXJf/JOYM=";
              };
            };

            files = {
              "config/mcsr/standardsettings.json" = {
                source = ./standardsettings.json;
                method = "copy";
              };
              "config/mcsr/sodium.json" = {
                source = ./sodium.json;
                method = "copy";
              };
              "config/mcsr/extra-options.json" = {
                source = ./sodium.json;
                method = "copy";
              };
            };

            binEntry = {
              enable = true;
              name = "ranked";
            };
          };
        };
      };

      programs.ninjabrain-bot = {
        enable = true;
        # stylix = false;
        # force = true;
        settings = {
          hotkey_decrement_code = 122955;
          hotkey_decrement_modifier = 0;
          hotkey_increment_code = 122957;
          hotkey_increment_modifier = 0;
          hotkey_lock_code = 65574;
          hotkey_lock_modifier = 0;
          hotkey_reset_code = 65555;
          hotkey_reset_modifier = 1;

          view = 1;
          all_advancements = false;
          mc_version = 0;
          sensitivity = 0.02291165;

          size = 1;

          default_boat_type = 2;
          alt_clipboard_reader = false;
          angle_adjustment_display_type = 1;
          angle_adjustment_type = 1;
          auto_reset = false;
          color_negative_coords = false;
          direction_help_enabled = true;
          show_angle_errors = true;
          show_angle_updates = true;
          sigma_boat = 0.0007;
          stronghold_display_type = 0;
          use_adv_statistics = true;
          use_precise_angle = true;

          sigma = 0.01;

          enable_http_server = true;
        };
      };

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
              ninb = "${lib.getExe config.programs.ninjabrain-bot.package}",
              overlay = "${./overlay.png}",
          }

          ${builtins.readFile ./waywall.lua}
        '';

        "xkb/symbols/mc".text = ''
          default partial alphanumeric_keys
          xkb_symbols "basic" {
              include "us(basic)"

              name[Group1] = "Minecraft";
          };
        '';
      };
    })

    (lib.mkIf cfg.niri.enable {
      home.pointerCursor = {
        enable = true;
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

            "Mod+P".action = set-dynamic-cast-window;
            "Mod+Shift+P".action = set-dynamic-cast-monitor;
            "Mod+C".action = clear-dynamic-cast-target;
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
            matches = [ { is-window-cast-target = true; } ];
            border = {
              active.color = "#${config.lib.stylix.colors.base0B}";
              inactive.color = "#${config.lib.stylix.colors.base0A}";
            };
          }
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
