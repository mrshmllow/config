{
  server.backups.paths = [
    "/var/lib/autobrr"
  ];

  services.autobrr = {
    enable = false;
    openFirewall = false;
    settings.port = 3005;
  };
}
