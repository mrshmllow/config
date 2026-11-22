{
  pkgs,
  inputs,
  ...
}:
{
  users.users.marsh.packages = [
    inputs.candy.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.candy.packages.${pkgs.stdenv.hostPlatform.system}.neovide
  ];

  environment.variables.EDITOR = "nvim";

  programs.fish.interactiveShellInit = ''
    set fish_greeting
    fish_vi_key_bindings
  '';

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.marsh = {
      imports = [ ../home ];
    };

    extraSpecialArgs = {
      inherit inputs;
    };
  };
}
