{ config, ... }:
{
  server.backups.paths = [
    config.services.bluesky-pds.settings.PDS_DATA_DIRECTORY
  ];

  services.bluesky-pds = {
    enable = true;
    environmentFiles = [ config.deployment.keys."pds.env".path ];
    goat.enable = true;
    pdsadmin.enable = true;
    settings = {
      PDS_BLOBSTORE_DISK_LOCATION = null;
      PDS_HOSTNAME = "pds.althaea.zone";
      PDS_PORT = 3006;
      PDS_BLOBSTORE_S3_ENDPOINT = "https://s3.us-east-005.backblazeb2.com";
      PDS_BLOBSTORE_S3_REGION = "us-east-005";
      PDS_BLOBSTORE_S3_BUCKET = "pds-blob-store";
    };
  };

  systemd.services.bluesky-pds.serviceConfig.Environment = [
    "NODE_OPTIONS=\"--network-family-autoselection-attempt-timeout=500\""
  ];

  services.caddy.virtualHosts."pds.althaea.zone".extraConfig = ''
    reverse_proxy http://localhost:${builtins.toString config.services.bluesky-pds.settings.PDS_PORT}
  '';

  deployment.keys."pds.env" = {
    keyCommand = [
      "gpg"
      "--decrypt"
      "${../../../../secrets/pds.env.gpg}"
    ];
    destDir = "/etc/keys";
  };
}
