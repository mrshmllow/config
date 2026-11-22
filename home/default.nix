{ inputs, ... }:
{
  imports = [
    ./shell
    ./hm-modules/desktop.nix
    inputs.noctalia.homeModules.default
    inputs.direnv-instant.homeModules.direnv-instant
    inputs.nixcraft.homeModules.default
  ];

  home.username = "marsh";

  home.stateVersion = "23.11";
}
