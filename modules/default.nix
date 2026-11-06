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
    ./server
  ];

  config = {
    services.avahi.enable = true;

    programs.fish.enable = true;

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
    ];
  };
}
