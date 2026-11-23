{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.desktop.mcsr;
in
{
  options.desktop.mcsr.enable = lib.mkEnableOption "mcsr";

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
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
  ];
}
