{ mkDeploymentKey, ... }:
{
  config = {
    server.caddy.enable = true;

    deployment.keys."cf.token" = mkDeploymentKey ../../secrets/media.cf.token.gpg { };
  };
}
