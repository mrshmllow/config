_:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./services
    ./caddy.nix
  ];

  server.openssh.enable = true;
  server.backups.enable = true;

  # for jetkvm usb connection
  boot.loader.timeout = 25;

  networking.hostName = "media"; # Define your hostname.

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPSvOZoSGVEpR6eTDK9OJ31MWQPF2s8oLc8J7MBh6nez marsh@maple"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEf5PCchOeMbngf8Ta+4qErlwGcColab/aw+vOx7ZZu+ marsh@althaea"
  ];

  services.nfs.server = {
    enable = true;
    exports = ''
      /storage/data/media         10.1.10.0/24(rw,fsid=0,no_subtree_check)
    '';
  };

  networking.firewall.allowedTCPPorts = [ 2049 ];

  system.stateVersion = "25.05"; # Did you read the comment?

}
