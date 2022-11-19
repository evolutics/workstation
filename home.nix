{
  config,
  pkgs,
  ...
}: {
  home = {
    homeDirectory = "/home/foo";

    packages = [
      pkgs.alejandra
      pkgs.ansible
      pkgs.git
      pkgs.pdftk
      pkgs.vscode
    ];

    stateVersion = "22.05";

    username = "foo";
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
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
      extraConfig = {
        core = {
          editor = "code --wait";
        };
      };
      userEmail = "foo@example.com";
      userName = "Foo Bar";
    };

    home-manager.enable = true;
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
