{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
let
  dataDir = "/var/lib/typstbot";

  common = {
    version = "locked";
    src = inputs.typst-bot;
    cargoHash = "sha256-OMVKzyaoODDyn1M6A4ulgEcGLw2QhDOK7rua2GAZts4=";
    nativeBuildInputs = [
      pkgs.git
    ];
  };

  worker = pkgs.rustPlatform.buildRustPackage (
    _:
    common
    // {
      pname = "typst-bot-worker";
      cargoBuildFlags = "-p worker";
      meta.mainProgram = "worker";
    }
  );

  package = pkgs.rustPlatform.buildRustPackage (
    _:
    common
    // {
      pname = "typst-bot";
      cargoBuildFlags = "-p typst-bot --no-default-features";
      meta.mainProgram = "typst-bot";
    }
  );
in
{
  systemd.services.typstbot = {
    script = lib.getExe package;
    after = [
      "network.target"
    ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      DB_PATH = "${dataDir}/sqlite/db.sqlite";
      CACHE_DIRECTORY = "${dataDir}/cache";
      TYPST_BOT_WORKER_PATH = lib.getExe worker;
    };
    serviceConfig = {
      EnvironmentFile = config.deployment.keys."typstbot.env".path;
      User = "typstbot";
      Group = "typstbot";
    };
    path = [ pkgs.typst ];
  };

  deployment.keys."typstbot.env" = {
    keyCommand = [
      "gpg"
      "--decrypt"
      "${../../../secrets/typstbot.env.gpg}"
    ];

    destDir = "/etc/keys";
    uploadAt = "post-activation";
    user = "typstbot";
    group = "typstbot";
  };

  users = {
    users.typstbot = {
      isSystemUser = true;
      group = "typstbot";
    };

    groups.typstbot = { };
  };

  systemd = {
    tmpfiles.rules = [
      "d ${dataDir} 0700 typstbot typstbot - -"
      "d ${dataDir}/cache 0700 typstbot typstbot - -"
      "d ${dataDir}/sqlite 0700 typstbot typstbot - -"
      "f ${dataDir}/sqlite/db.sqlite 0700 typstbot typstbot - -"
    ];
  };
}
