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

    amd = lib.mkEnableOption "amdgpu";

    gnome.enable = lib.mkEnableOption "gnome desktop";
    niri.enable = lib.mkEnableOption "niri wm";
    games.sc.enable = lib.mkEnableOption "star citizen";
    apps.davinci-resolve.enable = lib.mkEnableOption "davinci resolve";

    apps.carla.enable = lib.mkEnableOption "audio stuff";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home-manager.sharedModules = [
        {
          desktop.enable = true;
        }
      ];

      services = {
        displayManager.gdm.enable = true;

        flatpak.enable = true;
        earlyoom.enable = true;
      };

      boot.supportedFilesystems = [ "nfs" ];

      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      programs = {
        obs-studio = {
          enable = true;
          enableVirtualCamera = true;
          plugins = [
            pkgs.obs-studio-plugins.obs-pipewire-audio-capture
          ];
        };
        nix-ld.enable = true;

        steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;
          gamescopeSession.enable = true;
          extraCompatPackages = with pkgs; [
            proton-ge-bin
          ];
        };
      };

      # todo: document why?
      services.udev.extraRules = ''
        SUBSYSTEM=="usb", ATTR{idVendor}=="057e", ATTR{idProduct}=="2069", MODE="0666"
      '';

      nixpkgs.config.allowUnfreePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
          "rsi-launcher"
          "rsi-installer"
          "google-chrome"
          "intellij-idea"
          "citrix-workspace"
          "steam"
          "steam-unwrapped"
          "affinity-v3"
          "affinity-extracted-sources"
          "davinci-resolve"
        ];

      environment.systemPackages = with pkgs; [
        (google-chrome.override {
          # todo: r these needed anymore?
          commandLineArgs = [
            "--enable-features=VaapiVideoDecodeLinuxGL"
            "--ignore-gpu-blocklist"
            "--enable-zero-copy"
          ];
        })

        pkgs.affinity-v3
        pomodoro-gtk
        equibop
        killall
        (waywall.overrideAttrs {
          version = "unstable";
          src = inputs.waywall;
        })
        (prismlauncher.override {
          additionalLibs = [
            pkgs.libxtst
            pkgs.libxkbcommon
            pkgs.libxt
          ];
          additionalPrograms = [
            pkgs.zenity
            pkgs.which
          ];
          jdks = [
            inputs.mcsr-nixos.packages.${stdenv.hostPlatform.system}.graalvm-21
            pkgs.javaPackages.compiler.openjdk25
            pkgs.javaPackages.compiler.openjdk21
          ];
        })
        keepassxc
        jetbrains.idea
        heroic
        qbittorrent
        mangohud
        anki
        signal-desktop
        mpv
        feishin
        picard
        # citrix_workspace_25_08_10
        azahar
        jan
        yaak
        inputs.grimoire.packages.${pkgs.system}.default

        wl-clipboard
      ];

      boot.plymouth.enable = true;

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      fonts = {
        enableDefaultPackages = true;
        fontDir.enable = true;
        packages = with pkgs; [
          source-han-sans
          source-han-sans
          source-han-serif
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
          adwaita-fonts
        ];
      };

      stylix = {
        enable = true;

        image = pkgs.fetchurl {
          url = "https://files.catbox.moe/wqafpo.jpg";
          hash = "sha256-hV8B8GQf1Mbzepy0YbABe1207ms546EP76/3xFDUVYo=";
        };

        opacity.terminal = 1.0;

        polarity = "dark";

        base16Scheme = {
          yaml = pkgs.fetchurl {
            # previously: pine-rose-moon
            url = "https://github.com/tinted-theming/schemes/raw/refs/heads/spec-0.11/base16/solarized-light.yaml";
            hash = "sha256-npq2z6tkkE6FJQrgl6Ut/S3nveMg0opkmX6Gsf5C4wY=";
          };
        };

        fonts = {
          serif = {
            package = pkgs.dejavu_fonts;
            name = "DejaVu Serif";
          };

          sansSerif = {
            package = pkgs.dejavu_fonts;
            name = "DejaVu Sans";
          };

          monospace = {
            package = pkgs.maple-mono.NF;
            name = "Maple Mono NF";
          };

          emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };
        };
      };
    })

    (lib.mkIf cfg.amd {
      hardware.amdgpu.opencl.enable = true;
    })

    (lib.mkIf cfg.gnome.enable {
      services = {
        desktopManager.gnome = {
          enable = true;
          extraGSettingsOverridePackages = [ pkgs.mutter ];
          extraGSettingsOverrides = ''
            [org.gnome.mutter]
            experimental-features=['scale-monitor-framebuffer', 'xwayland-native-scaling', 'variable-refresh-rate']
          '';
        };

        pipewire = {
          enable = true;
          pulse.enable = true;
        };
      };

      environment.systemPackages = with pkgs; [
        gnomeExtensions.appindicator
        gnomeExtensions.clipboard-history
        gnome-sound-recorder
        sushi
        # gradia
      ];

      security.rtkit.enable = true;
    })

    (lib.mkIf cfg.niri.enable {
      home-manager.sharedModules = [
        {
          desktop.niri.enable = true;
        }
      ];

      programs.niri = {
        enable = true;
        # unstable was disabled because of build breakage from deprecated packages
        # package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
        package = pkgs.niri;
      };

      # must be enabled for noctalia
      hardware.bluetooth.enable = true;
      networking.networkmanager.enable = true;
      services = {
        power-profiles-daemon.enable = true;
        upower.enable = true;
      };

      xdg.portal = {
        enable = true;
        wlr.enable = true;
        xdgOpenUsePortal = true;
        config = {
          common = {
            default = [
              "gtk"
              "gnome"
            ];
          };
          niri = {
            default = [
              "gtk"
              "gnome"
            ];
          };
        };

        extraPortals = [
          pkgs.xdg-desktop-portal-wlr
          pkgs.xdg-desktop-portal-gtk
        ];
      };

      environment.systemPackages = with pkgs; [
        networkmanagerapplet
        pavucontrol
        nautilus
        file-roller
        cliphist
        pulseaudio
        gnome-disk-utility
        inputs.noctalia.packages.${stdenv.hostPlatform.system}.default
      ];
    })

    (lib.mkIf cfg.games.sc.enable {
      programs.gamemode.enable = true;

      programs.rsi-launcher = {
        enable = true;
        preCommands = ''
          export DXVK_HUD=compiler;
          export MANGO_HUD=1;
          export RADV_PERFTEST=nogttspill;
        '';

        patchXwayland = true;
        umu.enable = false;
      };

      nix.settings = {
        substituters = [
          "https://nix-citizen.cachix.org"
        ];
        trusted-public-keys = [
          "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="
        ];
      };
    })

    (lib.mkIf cfg.apps.davinci-resolve.enable {
      environment.systemPackages = with pkgs; [ davinci-resolve ];

      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          rocmPackages.clr.icd
        ];
      };
    })

    (lib.mkIf cfg.apps.carla.enable {
      environment = {
        systemPackages = with pkgs; [
          qpwgraph
          carla
          lsp-plugins
          calf
          deepfilternet
        ];

        # From https://discourse.nixos.org/t/lmms-vst-plugins/42985/3
        variables =
          let
            makePluginPath =
              format:
              (lib.makeSearchPath format [
                "$HOME/.nix-profile/lib"
                "/run/current-system/sw/lib"
                "/etc/profiles/per-user/$USER/lib"
              ])
              + ":$HOME/.${format}";
          in
          {
            DSSI_PATH = makePluginPath "dssi";
            LADSPA_PATH = makePluginPath "ladspa";
            LV2_PATH = makePluginPath "lv2";
            LXVST_PATH = makePluginPath "lxvst";
            VST_PATH = makePluginPath "vst";
            VST3_PATH = makePluginPath "vst3";
          };
      };
    })
  ];
}
