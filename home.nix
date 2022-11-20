{
  config,
  pkgs,
  ...
}: {
  home.username = "foo";
  home.homeDirectory = "/home/foo";

  home.stateVersion = "22.05";

  programs.home-manager.enable = true;
}
