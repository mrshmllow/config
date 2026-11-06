{
  pkgs,
  inputs,
  config,
  ...
}:
let
  matter-server-path = "/var/lib/matter-server";
in
{
  server.backups.paths = [
    config.services.home-assistant.configDir
    matter-server-path
  ];

  networking.firewall.allowedUDPPorts = [ 5353 ];

  boot = {
    kernel.sysctl = {
      "net.netfilter.nf_conntrack_udp_timeout" = 3600;
      "net.netfilter.nf_conntrack_udp_timeout_stream" = 3600;
    };

    kernelModules = [ "nf_conntrack" ];
  };

  # https://github.com/matter-js/matterjs-server/blob/main/docs/docker.md#running-the-matterjs-server-using-a-container-image
  virtualisation.oci-containers.containers.matter-server = {
    image = "ghcr.io/matter-js/matterjs-server:stable";
    volumes = [
      "${matter-server-path}:/data"
    ];
    extraOptions = [
      "--network=host"
    ];
    environment = {
      PORT = "3009";
      PRIMARY_INTERFACE = "eno1";
    };
  };

  systemd.tmpfiles.rules = [
    "d ${matter-server-path} 0775 1000 1000 - -"
  ];

  # name: New scene
  # entities:
  #   light.bedroom_bedside_lamp:
  #     min_color_temp_kelvin: 1801
  #     max_color_temp_kelvin: 6535
  #     supported_color_modes:
  #       - color_temp
  #       - hs
  #       - xy
  #     color_mode: hs
  #     brightness: 128
  #     color_temp_kelvin: null
  #     hs_color:
  #       - 303.307
  #       - 48.819
  #     rgb_color:
  #       - 255
  #       - 131
  #       - 248
  #     xy_color:
  #       - 0.374
  #       - 0.211
  #     friendly_name: Bedside Lamp
  #     supported_features: 32
  #     state: "on"
  #   light.bedroom_light_1:
  #     min_color_temp_kelvin: 1000
  #     max_color_temp_kelvin: 20000
  #     supported_color_modes:
  #       - color_temp
  #       - hs
  #       - xy
  #     color_mode: hs
  #     brightness: 153
  #     color_temp_kelvin: null
  #     hs_color:
  #       - 328.819
  #       - 98.819
  #     rgb_color:
  #       - 255
  #       - 3
  #       - 134
  #     xy_color:
  #       - 0.57
  #       - 0.24
  #     friendly_name: Room Overhead 1
  #     supported_features: 32
  #     state: "on"
  #   light.bedroom_light_2:
  #     min_color_temp_kelvin: 1000
  #     max_color_temp_kelvin: 20000
  #     supported_color_modes:
  #       - color_temp
  #       - hs
  #       - xy
  #     color_mode: hs
  #     brightness: 153
  #     color_temp_kelvin: null
  #     hs_color:
  #       - 219.685
  #       - 100
  #     rgb_color:
  #       - 0
  #       - 86
  #       - 255
  #     xy_color:
  #       - 0.138
  #       - 0.086
  #     friendly_name: Room Overhead 2
  #     supported_features: 32
  #     state: "on"
  # metadata: {}

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      settings.publish = {
        disable-publishing = false;
        publish-addresses = true;
        publish-workstation = true;
      };
    };

    home-assistant = {
      enable = true;

      config = {
        # apparently, this is going to be removed:
        # http = {
        #   server_port = 3008;
        #   use_x_forwarded_for = true;
        #   trusted_proxies = [
        #     "100.64.0.0/16" # netbird network range
        #   ];
        # };
        mobile_app = { };
        homeassistant = {
          time_zone = "Australia/Sydney";
          temperature_unit = "C";
          unit_system = "metric";
        };

        zone = [
          {
            name = "home";
            latitude = "-33.86418654257753";
            longitude = "151.2109816853725";
            radius = 100;
            icon = "mdi:home";
          }
        ];

        input_boolean = {
          wake_up_mode_tomorrow = {
            name = "Sunrise Mode Tomorrow";
            icon = "mdi:white-balance-sunny";
          };
        };

        light = [
          {
            platform = "group";
            name = "Room Overhead";
            entities = [
              "light.bedroom_light_1"
              "light.bedroom_light_2"
            ];
          }
        ];

        # many of these stolen from https://gist.github.com/Hypfer/a0a8b5b9429831a7306ec4300077eaaa
        scene =
          let
            default_room_overhead = {
              min_color_temp_kelvin = 1000;
              max_color_temp_kelvin = 20000;
              supported_color_modes = [
                "color_temp"
                "hs"
                "xy"
              ];
              color_mode = "hs";
              brightness = 255;
              color_temp_kelvin = null;
              hs_color = [
                0
                0
              ];
              rgb_color = [
                255
                255
                255
              ];
              xy_color = [
                0.323
                0.329
              ];
              entity_id = [
                "light.bedroom_light_1"
                "light.bedroom_light_2"
              ];
              icon = "mdi:lightbulb-group";
              friendly_name = "Room Overhead";
              supported_features = 32;
              state = "on";
            };

            metadata = {
              "light.room_overhead" = {
                entity_only = true;
              };
            };
          in
          [
            {
              name = "Night light";
              entities = {
                "light.room_overhead" = default_room_overhead // {
                  brightness = 1;
                  color_mode = "xy";
                  xy_color = [
                    0.561
                    0.4042
                  ];
                };
              };
              inherit metadata;
            }
            {
              name = "Energize";
              entities = {
                "light.room_overhead" = default_room_overhead // {
                  brightness = 254;
                  color_mode = "xy";
                  xy_color = [
                    0.3143
                    0.3301
                  ];
                };
              };
              inherit metadata;
            }
            {
              name = "Dreamy Dusk";
              entities =
                let
                  brightness = 51;
                in
                {
                  "light.bedroom_light_1" = default_room_overhead // {
                    inherit brightness;
                    color_mode = "xy";
                    xy_color = [
                      0.5189
                      0.3924
                    ];
                  };
                  "light.bedroom_light_2" = default_room_overhead // {
                    inherit brightness;
                    color_mode = "xy";
                    xy_color = [
                      0.5493
                      0.3702
                    ];
                  };
                };
              inherit metadata;
            }
            {
              name = "Blossom";
              entities =
                let
                  brightness = 203;
                in
                {
                  "light.bedroom_light_1" = default_room_overhead // {
                    inherit brightness;
                    color_mode = "xy";
                    xy_color = [
                      0.5119
                      0.4249
                    ];
                  };
                  "light.bedroom_light_2" = default_room_overhead // {
                    inherit brightness;
                    color_mode = "xy";
                    xy_color = [
                      0.4419
                      0.4164
                    ];
                  };
                };
              inherit metadata;
            }
          ];

        automation = [
          {
            description = "";
            use_blueprint = {
              path = "homeassistant/motion_light.yaml";
              input = {
                motion_entity = "binary_sensor.bedroom_motion_sensor_occupancy";
                light_target = {
                  entity_id = "light.room_overhead";
                };
              };
            };
          }
          {
            alias = "Automatically reset Wake Up Mode every morning";
            description = "";
            mode = "single";
            triggers = [
              {
                trigger = "time";
                at = "07:00:00";
              }
            ];
            conditions = [ ];
            actions = [
              {
                action = "input_boolean.turn_on";
                metadata = { };
                data = { };
                target = {
                  entity_id = "input_boolean.wake_up_mode_tomorrow";
                };
              }
            ];
          }
          {
            description = "";
            alias = "Wake Up Routine";
            mode = "single";
            triggers = [
              {
                trigger = "time";
                at = "06:30:00";
              }
            ];
            conditions = [
              {
                condition = "state";
                entity_id = "input_boolean.wake_up_mode_tomorrow";
                state = [ "on" ];
              }
            ];
            actions =
              let
                max_brightness = 250; # putting at 255 will never actually be reached and loop forever
                duration_minutes = 30;
              in
              [
                {
                  repeat = {
                    until = [
                      {
                        condition = "numeric_state";
                        entity_id = "light.room_overhead";
                        attribute = "brightness";
                        above = max_brightness;
                      }
                    ];
                    sequence = [
                      {
                        action = "light.turn_on";
                        metadata = { };
                        target = {
                          entity_id = "light.room_overhead";
                        };
                        data = {
                          brightness_step_pct = max_brightness / duration_minutes;
                          transition = 60; # 60 seconds
                          color_temp_kelvin = 2700;
                        };
                      }
                      {
                        delay = {
                          hours = 0;
                          minutes = 1; # wait a minute between iterations
                          seconds = 0;
                          milliseconds = 0;
                        };
                      }
                    ];
                  };
                }
              ];
          }
          {
            alias = "leah comes home";
            description = "";
            mode = "single";
            triggers = [
              {
                trigger = "state";
                entity_id = [
                  "device_tracker.pixel_7a_2"
                ];
                to = [
                  "home"
                ];
                from = null;
              }
            ];
            conditions = [ ];
            actions = [
              {
                action = "notify.mobile_app_pixel_7a";
                metadata = {
                };
                data = {
                  message = "leah is home";
                  title = "leah is home";
                };
              }
            ];
          }
        ];

        default_config = { };
      };

      extraComponents = [
        # Components required to complete the onboarding
        "analytics"
        "google_translate"
        "met"
        "radio_browser"
        "mobile_app"
        # "shopping_list"

        "unifi"
        "otbr"
        "matter"
        "group"
      ];

      customComponents = [
        (pkgs.buildHomeAssistantComponent {
          owner = "bremor";
          domain = "bureau_of_meteorology";
          version = "unstable";

          src = inputs.bom;

          dependencies = [
            pkgs.python314Packages.iso8601
          ];
        })
      ];
    };
  };
}
