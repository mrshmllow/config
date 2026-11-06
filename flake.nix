{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    git-hooks.url = "github:cachix/git-hooks.nix";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    candy.url = "git+https://tangled.org/@althaea.zone/candy?ref=trunk";
    wire.url = "github:forallsys/wire/trunk";

    # star citizen
    nix-citizen = {
      url = "github:LovingMelody/nix-citizen";
      inputs.nix-gaming.follows = "nix-gaming";
    };
    nix-gaming.url = "github:fufexan/nix-gaming";
    umu.url = "github:Open-Wine-Components/umu-launcher?dir=packaging/nix";
    grimoire.url = "github:Slush97/grimoire";

    typst-bot = {
      url = "github:mattfbacon/typst-bot";
      flake = false;
    };

    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    affinity-nix.url = "github:mrshmllow/affinity-nix";

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/cachix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ninb.url = "git+https://tangled.org/althaea.zone/ninjabrain-bot-nix?ref=trunk";

    mcsr-nixos = {
      url = "https://git.uku3lig.net/uku/mcsr-nixos/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko.url = "github:nix-community/disko";
    direnv-instant.url = "github:Mic92/direnv-instant";
    llm-agents.url = "github:numtide/llm-agents.nix";
    helium.url = "github:Nytelife26/nixpkgs/helium/init";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    bom = {
      url = "github:bremor/bureau_of_meteorology";
      flake = false;
    };

    waywall = {
      url = "github:tesselslate/waywall";
      flake = false;
    };
  };

  outputs =
    inputs@{
      home-manager,
      nixpkgs,
      nixos-hardware,
      git-hooks,
      nix-citizen,
      stylix,
      niri,
      self,
      ...
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-darwin"
        "i686-linux"
        "aarch64-linux"
      ];

      formatter =
        system: inputs.treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix;
    in
    {
      homeConfigurations.marsh = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        extraSpecialArgs = {
          inherit inputs;
        };
        modules = [
          ./home
          {
            home.homeDirectory = "/home/marsh";
          }
        ];
      };

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          pre-commit-check = git-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              fmt = {
                enable = true;
                name = "nix fmt";
                entry = "${pkgs.lib.getExe (formatter system).config.build.wrapper} --no-cache";
              };
              statix.enable = true;
              zizmor.enable = true;
              typos.enable = true;
              deadnix.enable = true;
            };
          };
        }
      );

      formatter = forAllSystems (system: (formatter system).config.build.wrapper);

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            inherit (self.checks.${system}.pre-commit-check) shellHook;

            buildInputs = pkgs.lib.flatten [
              self.checks.${system}.pre-commit-check.enabledPackages

              inputs.wire.packages.${system}.wire
              home-manager.packages.${system}.default
            ];
          };
        }
      );

      wire = inputs.wire.makeHive {
        meta = {
          nixpkgs = import inputs.nixpkgs {
            localSystem = "x86_64-linux";
            allowAliases = false;
          };
          specialArgs = {
            inherit inputs;
          };
        };

        defaults =
          {
            pkgs,
            name,
            lib,
            ...
          }:
          {
            imports = [
              ./nodes/${name}
              ./nix.nix
              ./modules
              home-manager.nixosModules.home-manager
              nix-citizen.nixosModules.StarCitizen
              stylix.nixosModules.stylix
              niri.nixosModules.niri
            ];

            nixpkgs.overlays = [
              inputs.affinity-nix.overlays.default
            ];

            nixpkgs.config.permittedInsecurePackages = [
              "dotnet-sdk-6.0.428"
              "olm-3.2.16"
              "aspnetcore-runtime-6.0.36"
              "pnpm-9.15.9"
              "libxml2-2.13.8"
              "libsoup-2.74.3"
            ];

            network.netbird.enable = true;

            nix.registry.nixpkgs =
              let
                # hacky way to figure out which nixpkgs flake is being used in this system
                # yell at michaili if this broke.
                currentNixpkgsFlake =
                  let
                    pkgsPathString = builtins.toString pkgs.path;
                  in
                  lib.findFirst (flake: flake.outPath == pkgsPathString) null (builtins.attrValues inputs);
              in
              lib.mkForce { flake = currentNixpkgsFlake; };
          };

        media = {
          deployment = {
            targetHost = [
              "10.1.10.151"
              "media"
            ];
            targetUser = "root";
            buildOnTarget = true;
          };

          nixpkgs.hostPlatform = "x86_64-linux";
        };

        maple = {
          deployment = {
            targetHost = "maple";
            targetUser = "root";
            buildOnTarget = true;
            allowLocalDeployment = true;
          };

          nixpkgs.hostPlatform = "x86_64-linux";

          imports = [
            ./marsh
            home-manager.nixosModules.home-manager
          ];
        };

        althaea = {
          deployment = {
            allowLocalDeployment = true;
          };

          nixpkgs.hostPlatform = "x86_64-linux";

          imports = [
            ./marsh
            home-manager.nixosModules.home-manager
            nixos-hardware.nixosModules.framework-12th-gen-intel
          ];
        };
      };
    };
}
