{
  config,
  pkgs,
  ...
}:
let
  homeserver_port = "8008";
in
{
  server.backups = {
    paths = [
      config.services.matrix-synapse.dataDir
      config.services.matrix-synapse.settings.media_store_path
    ];
    postgres-dbs = [ "matrix-synapse" ];
  };

  services = {
    matrix-synapse = {
      enable = true;
      extras = [ "oidc" ];
      settings = {
        public_baseurl = "https://matrix.althaea.zone/";
        media_store_path = "/storage/matrix-synapse-media";
        presence.enabled = true;
        server_name = "althaea.zone";
      };
      extraConfigFiles = [ config.deployment.keys."matrix.extra.yaml".path ];
    };

    postgresql.enable = true;
  };

  services.caddy.virtualHosts = {
    "matrix.althaea.zone".extraConfig = ''
      reverse_proxy /_matrix/* localhost:${homeserver_port}
      reverse_proxy /_synapse/client/* localhost:${homeserver_port}
    '';

    "matrix.althaea.zone:8448".extraConfig = ''
      reverse_proxy /_matrix/* localhost:${homeserver_port}
    '';

    "element.althaea.zone" =
      let
        web = pkgs.element-web.override {
          conf = {
            default_server_config.m.homeserver = {
              server_name = "althaea.zone";
              base_url = "https://matrix.althaea.zone";
            };
          };
        };
      in
      {
        extraConfig = ''
          root * ${web}
          file_server
        '';
      };

    "althaea.zone".extraConfig = ''
      header /.well-known/matrix/* Content-Type application/json
      header /.well-known/matrix/* Access-Control-Allow-Origin *
      respond /.well-known/matrix/server `{"m.server": "matrix.althaea.zone:443"}`
      respond /.well-known/matrix/client `{"m.homeserver":{"base_url":"https://matrix.althaea.zone"}}`
    '';
  };

  deployment.keys."matrix.extra.yaml" = {
    keyCommand = [
      "gpg"
      "--decrypt"
      "${../../../../secrets/matrix.extra.yaml.gpg}"
    ];
    destDir = "/etc/keys";
    group = "matrix-synapse";
    user = "matrix-synapse";
  };
}
