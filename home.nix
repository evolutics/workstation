{
  config,
  pkgs,
  ...
}: let
  customization = import ./customization.nix;
in {
  home = {
    file.".config/nix/nix.conf".text = ''
      experimental-features = flakes nix-command
    '';

    homeDirectory = "/home/${customization.username}";

    packages = let
      extra_packages = customization.extra_packages pkgs;
      standard_packages = with pkgs; [
        alejandra
        ansible
        docker
        flameshot
        keepassxc
        kubectl
        pdftk
        podman
        skaffold
        vagrant
        vlc
        xclip
      ];
    in
      standard_packages ++ extra_packages;

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

    direnv = {
      enable = true;
      nix-direnv.enable = true;
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
        kamadorueda.alejandra
        matklad.rust-analyzer
        streetsidesoftware.code-spell-checker
        timonwong.shellcheck
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
      "general/workspace_count" = 2;
    };
    xsettings = {
      "Net/ThemeName" = "Numix";
    };
  };
}
