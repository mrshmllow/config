{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [ ./gpg.nix ];

  xdg.configFile."AGENTS.md" = {
    text = ''
      `nix` (lix, nix3 cli) is available. You should `nix run nixpkgs#...` when binaries are otherwise not available in $PATH.

      I use `jj` for most projects, and you should probably use the jj log if it exists before trying a git log.
    '';
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    direnv-instant.enable = true;

    git = {
      enable = true;
      settings.user = {
        name = "marshmallow";
        email = "git@althaea.zone";
      };
      signing.format = null;
    };

    jujutsu = {
      enable = true;
      settings = {
        ui = {
          pager = "less -FRX";
          streampager = {
            show-ruler = false;
          };
          default-command = "log";

          diff-formatter = lib.flatten [
            (lib.getExe config.programs.difftastic.package)
            (lib.cli.toCommandLineGNU { } config.programs.difftastic.options)
            "$left"
            "$right"
          ];

          merge-editor = "mergiraf";
        };
        snapshot.auto-update-stale = true;
        git = {
          write-change-id-header = true;
        };
        user = {
          name = "marshmallow";
          email = "git@althaea.zone";
        };
        fsmonitor = {
          backend = "watchman";
          watchman.register-snapshot-trigger = true;
        };
        remotes.origin.auto-track-bookmarks = "marshmallow/*";
        templates = {
          git_push_bookmark = ''"marshmallow/p-" ++ change_id.short()'';
          draft_commit_description = ''
            concat(
              coalesce(description, default_commit_description, "\n"),
              surround(
                "\nJJ: This commit contains the following changes:\n", "",
                indent("JJ:     ", diff.stat(72)),
              ),
              "\nJJ: ignore-rest\n",
              diff.git(),
            )
          '';
        };

        # default tool, assuming `nix fmt` is a treefmt instance.
        fix.tools.nix-fmt-treefmt = {
          patterns = [ "glob:'**/**'" ];
          command = [
            "nix"
            "fmt"
            "--"
            "-vvv"
            "--stdin"
            "$path"
          ];
        };
      };
    };

    mergiraf = {
      enable = true;
      enableGitIntegration = false;
      enableJujutsuIntegration = true;
    };

    difftastic = {
      enable = true;
      options = {
        color = "always";
      };
    };

    ripgrep = {
      enable = true;
      arguments = [ "--trim" ];
    };

    fish = {
      enable = true;
      plugins = [
        {
          name = "z";
          inherit (pkgs.fishPlugins.z) src;
        }
        {
          name = "pisces";
          inherit (pkgs.fishPlugins.pisces) src;
        }
        {
          name = "puffer";
          inherit (pkgs.fishPlugins.puffer) src;
        }
      ];
    };

    eza = {
      enable = true;
      enableFishIntegration = true;
      git = true;
      icons = "auto";
      extraOptions = [
        "--group-directories-first"
        "--header"
      ];
    };

    starship = {
      enable = true;
      enableFishIntegration = true;
      enableTransience = true;

      settings = {
        # black, red, green, blue, yellow, purple, cyan, white
        format = ''\[$username@$hostname:$directory\]$character'';
        character = {
          success_symbol = "[\\$](bold purple)";
          error_symbol = "[\\$](bold red)";

          vimcmd_symbol = "[<](bold purple)";
          vimcmd_replace_one_symbol = "[<](bold red)";
          vimcmd_replace_symbol = "[<](bold red)";
          vimcmd_visual_symbol = "[<](bold cyan)";
        };
        username = {
          show_always = true;
          format = "[$user]($style)";
        };
        hostname = {
          ssh_only = false;
          format = "[$ssh_symbol$hostname]($style)";
        };
        directory = {
          format = "[$path]($style)[$read_only]($read_only_style)";
        };
      };
    };

    helix = {
      enable = true;
      package = pkgs.evil-helix;
    };
  };

  home = {
    shellAliases = {
      G = ''nvim +"G" +":only"'';
      s = "jj show";
      n = "jj new";

      m = "jj describe -m";
      mm = "jj describe";
      j = "jj squash";
      ji = "jj squash -i";
      x = "jj resolve";
      a = "jj abandon";

      v = "jj git fetch";
      w = "jj git push";
      ny = "jj bookmark advance";
    };

    # limit man pages to 80 cols
    # i find it hard to read when it spans my whole terminal
    sessionVariables.MANWIDTH = 80;

    packages = [
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.crush
    ]
    ++ lib.optional (config.programs.jujutsu.settings.fsmonitor.backend == "watchman") pkgs.watchman;
  };
}
