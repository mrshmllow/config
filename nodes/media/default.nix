{
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./services
    ./caddy.nix
  ];

  server.openssh.enable = true;
  server.backups.enable = true;

  boot.loader = {
    # Use the systemd-boot EFI boot loader.
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    # for jetkvm usb connection
    timeout = 25;
  };

  networking.hostName = "media"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Australia/Sydney";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    users = {
      marsh = {
        isNormalUser = true;
        extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPSvOZoSGVEpR6eTDK9OJ31MWQPF2s8oLc8J7MBh6nez marsh@maple"
        ];
      };
      root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPSvOZoSGVEpR6eTDK9OJ31MWQPF2s8oLc8J7MBh6nez marsh@maple"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEf5PCchOeMbngf8Ta+4qErlwGcColab/aw+vOx7ZZu+ marsh@althaea"
      ];
    };

    defaultUserShell = pkgs.fish;
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /storage/data/media         10.1.10.0/24(rw,fsid=0,no_subtree_check)
    '';
  };

  networking.firewall.allowedTCPPorts = [ 2049 ];

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
  ];

  system.stateVersion = "25.05"; # Did you read the comment?

}
