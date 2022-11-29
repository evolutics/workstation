{pkgs, ...}: let
  customization = import ./customization.nix;
in {
  home = {
    file = let
      base = {
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
        ".docker/daemon.json" = builtins.toJSON {
          ip = "127.0.0.1";
        };
      };
    in
      builtins.mapAttrs (file: contents: {
        text = contents;
      }) (base // customization.extra.files);

    homeDirectory = "/home/${customization.identity.username}";

    packages = let
      base = with pkgs; [
        alejandra
        ansible
        curl
        docker
        flameshot
        keepassxc
        kubectl
        minikube
        pdftk
        podman
        rustup
        skaffold
        vagrant
        vlc
      ];
      extra = customization.extra.packages pkgs;
    in
      base ++ extra;

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
      initExtra = ''
        export XDG_DATA_DIRS="$HOME/.nix-profile/share:$XDG_DATA_DIRS"
      '';
      shellAliases = {
        ls = "ls --color=auto";
      };
    };

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
      extensions = let
        base = with pkgs.vscode-extensions; [
          bbenoist.nix
          eamodio.gitlens
          esbenp.prettier-vscode
          kamadorueda.alejandra
          matklad.rust-analyzer
          streetsidesoftware.code-spell-checker
          timonwong.shellcheck
        ];
        extra = customization.extra.vscodeExtensions pkgs;
      in
        base ++ extra;
      userSettings = {
        "diffEditor.ignoreTrimWhitespace" = false;
        "editor.formatOnSave" = true;
        "editor.rulers" = [80];
        "workbench.editorAssociations" = {
          "git-rebase-todo" = "default";
        };
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
