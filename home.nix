{pkgs, ...}: let
  customization = import ./customization.nix;
in {
  home = {
    file = let
      standardFiles = {
        ".config/containers/policy.json" = builtins.toJSON {
          default = [
            {
              type = "insecureAcceptAnything";
            }
          ];
        };
        ".config/nix/nix.conf" = ''
          experimental-features = flakes nix-command
        '';
      };
    in
      builtins.mapAttrs (file: contents: {
        text = contents;
      }) (standardFiles // customization.extras.files);

    homeDirectory = "/home/${customization.identity.username}";

    packages = let
      extraPackages = customization.extras.packages pkgs;
      standardPackages = with pkgs; [
        alejandra
        ansible
        curl
        docker
        flameshot
        keepassxc
        kubectl
        minikube
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
      standardPackages ++ extraPackages;

    stateVersion = "22.05";

    username = customization.identity.username;
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    git = {
      diff-so-fancy.enable = true;
      enable = true;
      extraConfig = {
        core = {
          editor = "code --wait";
        };
      };
      package = pkgs.gitAndTools.gitFull;
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
        "workbench.editorAssociations" = {
          "git-rebase-todo" = "default";
        };
      };
    };

    zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "af-magic";
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
