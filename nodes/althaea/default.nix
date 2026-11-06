{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    inputs.auto-cpufreq.nixosModules.default
  ];

  desktop.enable = true;
  desktop.niri.enable = true;

  virtualisation.libvirtd.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    # Bootloader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  networking.hostName = "althaea";
  networking.nameservers = [ "1.1.1.1" ];

  time.timeZone = "Australia/Sydney";
  time.hardwareClockInLocalTime = true;

  virtualisation.docker.enable = true;

  services = {
    printing.enable = true;

    # https://knowledgebase.frame.work/en_us/optimizing-ubuntu-battery-life-Sye_48Lg3
    power-profiles-daemon.enable = lib.mkForce false;
    tlp.enable = false;
    thermald.enable = true;
    fwupd.enable = true;
  };

  programs = {
    gamemode.enable = true;
    auto-cpufreq.enable = true;
    virt-manager.enable = true;
    fuse.userAllowOther = true;
  };

  powerManagement.powertop.enable = true;

  system.stateVersion = "23.05";
}
