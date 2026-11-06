{ config, ... }:
{
  services.actual = {
    enable = true;
    settings = {
      port = 3000;
    };
  };

  server.backups.paths = [
    config.services.actual.settings.dataDir
  ];
}
