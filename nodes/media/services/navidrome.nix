{
  services.navidrome = {
    enable = true;
    withPlugins = p: [
      p.lyrics-plugin
    ];
    settings = {
      Address = "0.0.0.0";
      MusicFolder = "/storage/data/media/music";
      Port = 3012;
    };
    openFirewall = true;
  };
}
