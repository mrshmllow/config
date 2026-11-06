{ config, ... }:
{
  services.pocket-id = {
    enable = true;

    settings = {
      TRUST_PROXY = true;
      APP_URL = "https://id.althaea.zone";
      ANALYTICS_DISABLED = true;
      PORT = "1411";
    };

    environmentFile = config.deployment.keys."pocket-id.env".path;
  };

  services.caddy.virtualHosts = {
    "id.althaea.zone".extraConfig = ''
      reverse_proxy http://localhost:${config.services.pocket-id.settings.PORT}
    '';
  };

  server.backups.paths = [
    "/var/lib/pocket-id"
  ];

  deployment.keys."pocket-id.env" = {
    keyCommand = [
      "gpg"
      "--decrypt"
      "${../../../../secrets/pocket-id.env.gpg}"
    ];
    destDir = "/etc/keys";
    user = "pocket-id";
    group = "pocket-id";
  };
}
