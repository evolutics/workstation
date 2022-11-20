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

    homeDirectory = "/home/${customization.identity.username}";

    packages = let
      extra_packages = customization.extras.packages pkgs;
      standard_packages = with pkgs; [
        alejandra
        ansible
        curl
        docker
        flameshot
        keepassxc
        kubectl
        nodePackages.npm
        pdftk
        podman
        rustup
        skaffold
        vagrant
        vlc
        xclip
      ];
    in
      standard_packages ++ extra_packages;

    stateVersion = "22.05";

    username = customization.identity.username;
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
      userEmail = customization.identity.email;
      userName = customization.identity.name;
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
