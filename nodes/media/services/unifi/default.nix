{
  services.unifi = {
    enable = true;
    openFirewall = true;
  };

  server.backups.paths = [
    "/var/lib/unifi"
  ];

  networking.firewall.allowedTCPPorts = [ 8443 ];

  nixpkgs.config.allowUnfree = true;
}
