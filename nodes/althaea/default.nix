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

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "althaea";
  networking.nameservers = [ "1.1.1.1" ];

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

  programs.auto-cpufreq.enable = true;

  powerManagement.powertop.enable = true;

  system.stateVersion = "23.05";
}
