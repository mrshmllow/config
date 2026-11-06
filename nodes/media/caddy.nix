{
  config = {
    server.caddy.enable = true;

    deployment.keys."cf.token" = {
      keyCommand = [
        "gpg"
        "--decrypt"
        "${../../secrets/media.cf.token.gpg}"
      ];

      destDir = "/etc/keys";
    };
  };
}
