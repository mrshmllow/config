_: {
  _module.args.mkDeploymentKey =
    path: extra:
    {
      keyCommand = [
        "gpg"
        "--decrypt"
        (toString path)
      ];
      destDir = "/etc/keys";
    }
    // extra;
}
