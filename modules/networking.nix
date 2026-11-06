{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.network;
in
{
  options.network = {
    netbird.enable = lib.mkEnableOption "netbird node";
  };

  config = lib.mkMerge [
    {
      networking.networkmanager.enable = true;
    }

    (lib.mkIf cfg.netbird.enable {
      services.netbird = {
        enable = true;
        clients.default = {
          environment = {
            NB_MANAGEMENT_URL = "https://netbird.forall.systems";
          };
          login = {
            enable = true;
            setupKeyFile = config.deployment.keys."netbird.key".path;
            systemdDependencies = [
              config.deployment.keys."netbird.key".service
            ];
          };
        };
      };

      systemd.services.${config.services.netbird.clients.default.service.name}.path = [ pkgs.shadow ];

      deployment.keys."netbird.key" = {
        keyCommand = [
          "gpg"
          "--decrypt"
          "${../secrets/netbird.key.gpg}"
        ];
        destDir = "/etc/keys";
      };
    })
    (lib.mkIf (config.desktop.enable && cfg.netbird.enable) {
      services.netbird.clients.default.ui.enable = true;
    })
  ];
}
