let
  customization = import ./customization.nix;
in
  {
    config,
    pkgs,
    ...
  }: {
    home = {
      file.".config/nix/nix.conf".text = ''
        experimental-features = flakes nix-command
      '';

      homeDirectory = "/home/${customization.username}";

      packages = with pkgs; [
        alejandra
        ansible
        docker
        flameshot
        git
        keepassxc
        pdftk
        vagrant
        vlc
        vscode
        vscode-extensions.eamodio.gitlens
        vscode-extensions.esbenp.prettier-vscode
        vscode-extensions.streetsidesoftware.code-spell-checker
        xclip
      ];

      stateVersion = "22.05";

      username = customization.username;
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
        userEmail = customization.email;
        userName = customization.name;
      };

      home-manager.enable = true;

      vscode = {
        enable = true;
        extensions = with pkgs.vscode-extensions; [
          eamodio.gitlens
          esbenp.prettier-vscode
          streetsidesoftware.code-spell-checker
        ];
        userSettings = {
          "diffEditor.ignoreTrimWhitespace" = false;
          "editor.formatOnSave" = true;
          "editor.rulers" = [80];
        };
      };
    };

    xfconf.settings = {
      xfce4-keyboard-shortcuts = {
        "commands/custom/Print" = "flameshot gui";
      };
      xfwm4 = {
        "general/theme" = "Numix";
      };
      xsettings = {
        "Net/ThemeName" = "Numix";
      };
    };
  }
