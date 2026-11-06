{ config, lib, ... }:
let
  cfg = config.server.openssh;
in
{
  options.server.openssh = {
    enable = lib.mkEnableOption "openssh config";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };
  };
}
