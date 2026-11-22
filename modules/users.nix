{ pkgs, ... }:
{
  users.users.marsh = {
    isNormalUser = true;
    description = "marsh";
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "input"
      "dialout"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPSvOZoSGVEpR6eTDK9OJ31MWQPF2s8oLc8J7MBh6nez marsh@maple"
    ];
  };
}
