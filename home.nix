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
        rustup
        skaffold
        texlive.combined.scheme-medium
        vagrant
        variety
        virt-manager
        vlc

        merriweather
        open-sans
        roboto
        roboto-slab
      ];
      extra = customization.extra.packages pkgs;
    in
      base ++ extra;

    sessionVariables = {
      GIT_COMPLETION_CHECKOUT_NO_GUESS = 1;
    };

    stateVersion = "24.05";

    inherit (customization.identity) username;
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    bash = {
      enable = true;
      historyControl = ["ignoreboth"];
      initExtra = builtins.readFile ./configuration/bash_init_extra.sh;
      shellAliases = {
        a = "git branch && git status";
        grep = "grep --color=auto";
        ll = "ls --all --classify -l";
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
      aliases =
        builtins.mapAttrs (alias: script: "!${pkgs.lib.strings.removeSuffix
          "\n" (builtins.readFile script)}")
        {
          d1 = ./configuration/git_aliases/d1.sh;
          is-clean = ./configuration/git_aliases/is_clean.sh;
          lift = ./configuration/git_aliases/lift.sh;
          restart = ./configuration/git_aliases/restart.sh;
          save = ./configuration/git_aliases/save.sh;
          trim = ./configuration/git_aliases/trim.sh;
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
          ms-python.black-formatter
          rust-lang.rust-analyzer
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
