{pkgs, ...}: let
  customization = import ./customization.nix;
in {
  fonts.fontconfig.enable = true;

  home = {
    file = let
      base = {
        ".config/autostart/custom.desktop" = ''
          [Desktop Entry]
          Exec=/home/${customization.identity.username}/.config/home-manager/configuration/autostart.sh
          Name=Custom autostart
          Type=Application
        '';
        ".config/containers/policy.json" = builtins.toJSON {
          default = [
            {
              type = "insecureAcceptAnything";
            }
          ];
        };
        ".config/containers/registries.conf" = ''
          [[registry]]
          location = "docker.io"
          [[registry.mirror]]
          location = "mirror.gcr.io"
        '';
        ".config/nix/nix.conf" = ''
          experimental-features = flakes nix-command
        '';
        ".docker/daemon.json" = builtins.toJSON {
          ip = "127.0.0.1";
          registry-mirrors = ["https://mirror.gcr.io"];
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
        black
        curl
        flameshot
        git-absorb
        haskellPackages.hadolint
        jq
        keepassxc
        kubectl
        minikube
        nodePackages.prettier
        pdftk
        podman
        podman-compose
        roboto
        rustup
        skaffold
        texlive.combined.scheme-medium
        vagrant
        variety
        virt-manager
        vlc
      ];
      extra = customization.extra.packages pkgs;
    in
      base ++ extra;

    stateVersion = "23.05";

    username = customization.identity.username;
  };

  nixpkgs.config = {
    # As `allowUnfree = true` does not work, we use the following instead
    # (see https://github.com/nix-community/home-manager/issues/2942).
    allowUnfreePredicate = _: true;
  };

  programs = {
    bash = {
      enable = true;
      historyControl = ["ignoredups" "ignorespace"];
      initExtra = builtins.readFile ./configuration/bash_init_extra.sh;
      shellAliases = {
        a = "git status";
        ls = "ls --color=auto";
      };
    };

    direnv = {
      config = {
        global = {
          strict_env = true;
        };
      };
      enable = true;
      nix-direnv.enable = true;
    };

    git = {
      aliases = {
        d1 = "!${builtins.readFile ./configuration/git_aliases/d1.sh}";
        is-clean = "!${builtins.readFile ./configuration/git_aliases/is_clean.sh}";
        lift = "!${builtins.readFile ./configuration/git_aliases/lift.sh}";
        restart = "!${builtins.readFile ./configuration/git_aliases/restart.sh}";
        save = "!${builtins.readFile ./configuration/git_aliases/save.sh}";
        trim = "!${builtins.readFile ./configuration/git_aliases/trim.sh}";
      };
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
          ms-python.black-formatter
          streetsidesoftware.code-spell-checker
          timonwong.shellcheck
        ];
        extra = customization.extra.vscodeExtensions pkgs;
      in
        base ++ extra;
      userSettings = {
        "[python]" = {
          "editor.defaultFormatter" = "ms-python.black-formatter";
        };
        "diffEditor.ignoreTrimWhitespace" = false;
        "editor.formatOnSave" = true;
        "editor.inlayHints.enabled" = "offUnlessPressed";
        "editor.rulers" = [80];
        "workbench.editorAssociations" = {
          "git-rebase-todo" = "default";
        };
      };
    };
  };

  # The following makes `xdg.mimeApps.defaultApplications` work.
  targets.genericLinux.enable = true;

  xdg = {
    enable = true;
    mimeApps = {
      defaultApplications = {"text/plain" = ["code.desktop"];};
      enable = true;
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
