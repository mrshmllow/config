{ config, pkgs, ... }:
{
  services = {
    qbittorrent = {
      enable = true;
      openFirewall = true;
      webuiPort = 3007;
      torrentingPort = 38346;
      serverConfig = {
        Preferences = {
          WebUI = {
            RootFolder = "${pkgs.vuetorrent}/share/vuetorrent";
            Password_PBKDF2 = "Z/bIFekWWbZbyG/sBEIPVA==:2XkBQz8C36N7nrLiX8coUJOV914lIHCLOkliN3B7/f2xbNlHS46ZW7FYQm2Yv1mygIqH5z1UE2WbBAQoRWcxmw==";
            AlternativeUIEnabled = true;
          };
          # 23:00
          Scheduler.end_time = "000xfx4xefmx80";
        };
        BitTorrent.Session =
          let
            unlimited = -1;
          in
          {
            AlternativeGlobalDLSpeedLimit = 1000;
            AlternativeGlobalUPSpeedLimit = unlimited;
            UseAlternativeGlobalSpeedLimit = true;

            BandwidthSchedulerEnabled = true;

            AnonymousModeEnabled = true;

            Preallocation = true;
            TempPathEnabled = true;

            DefaultSavePath = "/storage/data/torrents/";
            TempPath = "/storage/data/incomplete/";

            UseCategoryPathsInManualMode = true;

            # GlobalMaxSeedingMinutes = 8 * 1440 + 3 * 60;
            GlobalMaxSeedingMinutes = unlimited;
            GlobalMaxRatio = 1;

            MaxActiveDownloads = unlimited;
            MaxActiveTorrents = unlimited;
            MaxActiveUploads = unlimited;
            MaxConnections = unlimited;
            MaxConnectionsPerTorrent = unlimited;
            MaxUploads = unlimited;
            MaxUploadsPerTorrent = unlimited;
          };
      };
    };
  };

  server.backups.paths = [
    config.services.qbittorrent.profileDir
  ];

  boot.kernelModules = [ "wireguard" ];
}
