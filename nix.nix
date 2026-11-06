{ pkgs, lib, ... }:
{
  nix = {
    package = pkgs.lix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operator"
      ];
      auto-optimise-store = true;
      substituters = lib.mkForce [
        "https://cache.nixos.org?priority=1"
        "https://cache.forall.systems?priority=2"
        "https://nix-community.cachix.org?priority=10"
        "https://cache.numtide.com?priority=10"
      ];
      trusted-users = [ "marsh" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.forall.systems:5PmD7QO4MSF8YgyRZtkSGXRDo96H3bybIf2SsQh8ScI="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
