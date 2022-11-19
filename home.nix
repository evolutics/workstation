{
  config,
  pkgs,
  ...
}: {
  home = {
    username = "foo";
    homeDirectory = "/home/foo";

    packages = [
      pkgs.ansible
      pkgs.git
      pkgs.pdftk
      pkgs.vscode
    ];

    stateVersion = "22.05";
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    home-manager.enable = true;

    bash = {
      enable = true;
      historyControl = ["ignoredups" "ignorespace"];
      historyFileSize = 200000;
      historySize = 100000;
      shellAliases = {
        ls = "ls --color=auto";
      };
    };

    git = {
      enable = true;
      userName = "Foo Bar";
      userEmail = "foo@example.com";
    };
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
