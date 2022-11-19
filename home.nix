{
  config,
  pkgs,
  ...
}: {
  home.username = "foo";
  home.homeDirectory = "/home/foo";

  home.packages = [
    pkgs.git
    pkgs.ansible
  ];

  home.stateVersion = "22.05";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Foo Bar";
    userEmail = "foo@example.com";
  };

  xfconf.settings = {
    xfwm4 = {
      "general/theme" = "Numix";
    };
    xsettings = {
      "Net/ThemeName" = "Numix";
    };
  };
}
