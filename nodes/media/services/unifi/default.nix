{
  services.unifi = {
    enable = true;
    openFirewall = true;
  };

  server.backups.paths = [
    "/var/lib/unifi"
  ];

  networking.firewall.allowedTCPPorts = [ 8443 ];

  services.caddy.virtualHosts."unifi.althaea.zone".extraConfig = ''
    reverse_proxy http://localhost:8443

    tls {
        dns cloudflare {$CLOUDFLARE_API_TOKEN}
    }
  '';

  nixpkgs.config.allowUnfree = true;
}
