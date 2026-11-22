{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  desktop = {
    enable = true;
    amd = true;
    niri.enable = true;
    games = {
      sc.enable = true;
      mcsr.enable = true;
    };
    apps = {
      carla.enable = true;
      davinci-resolve.enable = true;
    };
  };

  hardware.keyboard.qmk.enable = true;

  services = {
    pcscd.enable = true;
    udev.packages = with pkgs; [
      yubikey-personalization
      libu2f-host
    ];
    postgresql.enable = true;
  };

  environment.systemPackages = with pkgs; [
    yubikey-personalization
    ollama-vulkan
  ];

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    # kernelPackages = pkgs.linuxPackages_zen;
    kernelPackages = pkgs.linuxPackages_latest;
  };

  nix.settings.extra-platforms = config.boot.binfmt.emulatedSystems;

  server.backups = {
    enable = true;
    paths = [
      # "/home/marsh/.local/share/bottles"
    ];
  };

  virtualisation = {
    libvirtd.qemu = {
      swtpm.enable = true;
      vhostUserPackages = [ pkgs.virtiofsd ];
    };
    podman.enable = true;
    waydroid = {
      enable = true;
      package = pkgs.waydroid-nftables;
    };
  };

  # https://wiki.starcitizen-lug.org/Performance-Tuning#zram--swap
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024; # 8gb
    }
  ];
  zramSwap = {
    enable = true;
    memoryMax = 32 * 1024 * 1024 * 1024; # 32gb
  };

  networking.hostName = "maple";

  system.stateVersion = "24.05"; # Did you read the comment?
}
