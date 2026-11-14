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
    games.sc.enable = false;
    apps = {
      carla.enable = true;
      davinci-resolve.enable = true;
    };
  };

  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    keyboard.qmk.enable = true;
    cpu.amd.updateMicrocode = true;
  };

  services = {
    blueman.enable = true;
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
    kernelPackages = pkgs.linuxPackages_zen;

    # Use the systemd-boot EFI boot loader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  nix.settings.extra-platforms = config.boot.binfmt.emulatedSystems;

  server.backups = {
    enable = true;
    paths = [
      # "/home/marsh/.local/share/bottles"
    ];
  };

  programs = {
    obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      plugins = [
        pkgs.obs-studio-plugins.obs-pipewire-audio-capture
      ];
    };
    virt-manager.enable = true;
    fuse.userAllowOther = true;
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        vhostUserPackages = [ pkgs.virtiofsd ];
      };
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

  time.timeZone = "Australia/Sydney";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.marsh = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "libvirtd"
    ]; # Enable ‘sudo’ for the user.
  };

  system.stateVersion = "24.05"; # Did you read the comment?
}
