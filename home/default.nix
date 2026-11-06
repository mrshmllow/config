{ inputs, ... }:
{
  imports = [
    ./shell
    ./hm-modules/desktop.nix
    inputs.noctalia.homeModules.default
    # inputs.ninb.homeModules.default
    inputs.direnv-instant.homeModules.direnv-instant
  ];

  home.username = "marsh";

  home.stateVersion = "23.11";
}
