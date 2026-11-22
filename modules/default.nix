{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./desktop.nix
    ./networking.nix
    ./secrets.nix
    ./server
    ./users.nix
  ];

  config = {
    services.avahi.enable = true;

    programs.fish.enable = true;

    users.defaultUserShell = lib.mkForce pkgs.fish;

    time.timeZone = lib.mkDefault "Australia/Sydney";

    boot.loader = {
      systemd-boot.enable = lib.mkDefault true;
      efi.canTouchEfiVariables = lib.mkDefault true;
    };

    system.activationScripts.diff = {
      supportsDryActivation = true;
      text = ''
        if [ -e /run/current-system ]; then
          PATH=${lib.makeBinPath [ config.nix.package ]} \
            ${lib.getExe pkgs.nvd} \
            diff /run/current-system $systemConfig
        fi
      '';
    };

    # shared between all
    environment.systemPackages = [
      pkgs.btop
      pkgs.nix-index
      pkgs.sshfs
      pkgs.comma
      pkgs.vim
      pkgs.git
      pkgs.wget
    ];
  };
}
