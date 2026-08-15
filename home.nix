{
  lib,
  pkgs,
  ...
}: let
  customization = import ./customization.nix;
in {
  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      sources = [
        (lib.hm.gvariant.mkTuple ["xkb" "de+neo"])
        (lib.hm.gvariant.mkTuple ["xkb" "us"])
      ];
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Yaru-dark";
      icon-theme = "Yaru-dark";
    };
    "org/gnome/mutter" = {workspaces-only-on-primary = false;};
    "org/gnome/settings-daemon/plugins/color" = {night-light-enabled = true;};
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = ["/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"];
      power = ["<Control><Alt>BackSpace"];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Ctrl>Print";
      # Workaround for https://github.com/flameshot-org/flameshot/issues/3365.
      command = "script --command 'flameshot gui' /dev/null";
      name = "Take editable screenshot";
    };
    "org/gnome/shell/extensions/dash-to-dock" = {dock-fixed = false;};
    "org/gnome/shell/extensions/tiling-assistant" = {
      disable-tile-groups = true;
      enable-tiling-popup = false;
    };
  };

  fonts.fontconfig.enable = true;

  home = {
    file =
      {
        ".config/autostart/apply.desktop".text = ''
          [Desktop Entry]
          Comment=Update system by applying user config
          # Fall back to shell so errors stay visible to user.
          Exec=sh -c "''${HOME}/.config/home-manager/scripts/apply.sh || ''${SHELL}"
          Name=Apply config
          Terminal=true
          Type=Application
        '';
        ".config/Code/User/settings.json".text = builtins.toJSON {
          "[javascript]" = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
          "[json]" = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
          "[python]" = {
            "editor.defaultFormatter" = "charliermarsh.ruff";
          };
          "dev.containers.defaultExtensions" = [
            "bierner.markdown-mermaid"
            "charliermarsh.ruff"
            "eamodio.gitlens"
            "esbenp.prettier-vscode"
            "HashiCorp.terraform"
            "ms-python.python"
            "redhat.ansible"
            "streetsidesoftware.code-spell-checker"
            "timonwong.shellcheck"
          ];
          "dev.containers.dockerPath" = "podman";
          "diffEditor.ignoreTrimWhitespace" = false;
          "editor.formatOnSave" = true;
          "editor.inlayHints.enabled" = "offUnlessPressed";
          "editor.rulers" = [80];
          "workbench.editorAssociations" = {"git-rebase-todo" = "default";};
        };
        ".config/containers/policy.json".text = builtins.toJSON {
          default = [{type = "insecureAcceptAnything";}];
        };
        ".config/containers/registries.conf".text = ''
          [[registry]]
          location = "docker.io"
          [[registry.mirror]]
          location = "mirror.gcr.io"
        '';
        ".config/containers/storage.conf".text = ''
          [storage]
          # Workaround for https://github.com/microsoft/vscode/issues/232863.
          driver = "overlay"
          graphroot = "$HOME/.local/share/containers/storage"
        '';
        ".config/nix/nix.conf".text = ''
          experimental-features = flakes nix-command
        '';
      }
      // customization.extra_files;

    homeDirectory = "/home/${customization.identity.username}";

    packages =
      (with pkgs; [
        alejandra
        curl
        docker-client
        flameshot
        gcc
        gimp
        git-absorb
        git-delete-merged-branches
        hadolint
        imagemagick
        jq
        kubectl
        minikube
        pandoc
        pdftk
        podman
        prettier
        ruff
        rustup
        skaffold
        texliveMedium
        tilt
        vagrant
        variety
        virt-manager

        # Font families:
        merriweather
        open-sans
        roboto
        roboto-slab
      ])
      ++ customization.extra_packages pkgs;

    sessionPath = ["$HOME/.local/bin"];

    sessionVariables = {
      EDITOR = "nano";
      GIT_COMPLETION_CHECKOUT_NO_GUESS = 1;
    };

    # When updating state version, check Home Manager release notes for changes.
    stateVersion = "26.05"; # Update-worthy.

    inherit (customization.identity) username;
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    bash = {
      enable = true;
      historyControl = ["ignoredups" "ignorespace"];
      initExtra = builtins.readFile ./configuration/bash_init_extra.sh;
      shellAliases = {
        a = "git branch && git status";
        grep = "grep --color=auto";
        ll = "ls --all --classify -l";
        ls = "ls --color=auto";
      };
    };

    diff-so-fancy = {
      enable = true;
      enableGitIntegration = true;
    };

    direnv = {
      config = {global = {strict_env = true;};};
      enable = true;
      nix-direnv.enable = true;
    };

    git = {
      enable = true;
      package = pkgs.gitFull;
      settings = {
        alias =
          builtins.mapAttrs (_: script: "!${lib.fileContents script}")
          {
            d1 = ./configuration/git_aliases/d1.sh;
            is-clean = ./configuration/git_aliases/is_clean.sh;
            lift = ./configuration/git_aliases/lift.sh;
            restart = ./configuration/git_aliases/restart.sh;
            save = ./configuration/git_aliases/save.sh;
          };
        core.editor = "code --wait";
        user = {inherit (customization.identity) email name;};
      };
    };

    home-manager.enable = true;
  };

  targets.genericLinux.enable = true;

  xdg = {
    configFile = {
      "systemd/user/podman.service".source = "${pkgs.podman}/share/systemd/user/podman.service";
      "systemd/user/podman.socket".source = "${pkgs.podman}/share/systemd/user/podman.socket";
      "systemd/user/sockets.target.wants/podman.socket".source = "${pkgs.podman}/share/systemd/user/podman.socket";
    };
    enable = true;
    mimeApps = {
      defaultApplications = {"text/plain" = ["code_code.desktop"];};
      enable = true;
    };
  };
}
