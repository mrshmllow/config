{ config, ... }:
{
  server.backups.paths = [
    config.services.sonarr.dataDir
    config.services.radarr.dataDir
    config.services.prowlarr.dataDir
  ];

  services = {
    sonarr = {
      enable = true;
      settings.server.port = 3001;
    };

    radarr = {
      enable = true;
      settings.server.port = 3002;
    };

    prowlarr = {
      enable = true;
      settings.server.port = 3003;
    };

    lidarr = {
      enable = true;
      settings.server.port = 3010;
    };

    slskd = {
      enable = true;
      domain = null; # why?! do we keep doing this... stop forcing nginx pls :(
      environmentFile = config.deployment.keys."slskd.env".path;
      openFirewall = true;
      settings = {
        port = 3004;
        web.port = 3011;
        soulseek.listen_port = 50300;

        # web.url_base = "slskd.home.althaea.zone";
        directories.incomplete = "/storage/data/incomplete/slskd";
        directories.downloads = "/storage/data/media/music";
        shares.directories = [
          "/storage/data/media/shared"
        ];
      };
    };
  };

  deployment.keys."slskd.env" = {
    keyCommand = [
      "gpg"
      "--decrypt"
      "${../../../../secrets/media.slskd.env.gpg}"
    ];
    destDir = "/etc/keys";
  };
}
