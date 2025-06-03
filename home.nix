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
    "org/gnome/shell/extensions/tiling-assistant" = {enable-tiling-popup = false;};
  };

  fonts.fontconfig.enable = true;

  home = {
    file =
      {
        ".config/autostart/minimal_update.desktop".text = ''
          [Desktop Entry]
          Comment=Update custom code, keeping terminal open on errors
          Exec=sh -c ".config/home-manager/scripts/apply.sh minimal || ''${SHELL}"
          Name=Minimal update
          Terminal=true
          Type=Application
        '';
        ".config/Code/User/settings.json".text = builtins.toJSON {
          "[javascript]" = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
          "[python]" = {
            "editor.defaultFormatter" = "ms-python.black-formatter";
          };
          "diffEditor.ignoreTrimWhitespace" = false;
          "editor.formatOnSave" = true;
          "editor.inlayHints.enabled" = "offUnlessPressed";
          "editor.rulers" = [80];
          "workbench.editorAssociations" = {"git-rebase-todo" = "default";};
          # Workaround for https://github.com/microsoft/vscode/issues/232361.
          "workbench.externalBrowser" = "firefox";
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
        ".config/nix/nix.conf".text = ''
          experimental-features = flakes nix-command
        '';
      }
      // customization.extra_files;

    homeDirectory = "/home/${customization.identity.username}";

    packages =
      (with pkgs; [
        alejandra
        black
        curl
        docker
        flameshot
        gcc
        gimp
        git-absorb
        haskellPackages.hadolint
        imagemagick
        jq
        kubectl
        minikube
        nodePackages.prettier
        pandoc
        pdftk
        rustup
        skaffold
        texliveMedium
        unstable.podman
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

    sessionVariables = {
      DOCKER_HOST = "unix://\${XDG_RUNTIME_DIR}/podman/podman.sock";
      EDITOR = "nano";
      GIT_COMPLETION_CHECKOUT_NO_GUESS = 1;
    };

    # When updating state version, check Home Manager release notes for changes.
    stateVersion = "24.11"; # Update-worthy.

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

    direnv = {
      config = {global = {strict_env = true;};};
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
      extraConfig = {core = {editor = "code --wait";};};
      package = pkgs.gitAndTools.gitFull;
      userEmail = customization.identity.email;
      userName = customization.identity.name;
    };

    home-manager.enable = true;
  };

  systemd.user = {
    enable = true;

    # Source: https://github.com/containers/podman/tree/main/contrib/systemd
    services.podman = {
      Unit = {
        Description = "Podman API Service";
        Requires = "podman.socket";
        After = "podman.socket";
        Documentation = ["man:podman-system-service(1)"];
        StartLimitIntervalSec = 0;
      };
      Service = {
        Delegate = true;
        Type = "exec";
        KillMode = "process";
        Environment = "LOGGING='--log-level=info'";
        ExecStart = "%h/.nix-profile/bin/podman $LOGGING system service";
      };
      Install = {WantedBy = ["default.target"];};
    };
    sockets.podman = {
      Unit = {
        Description = "Podman API Socket";
        Documentation = ["man:podman-system-service(1)"];
      };
      Socket = {
        ListenStream = "%t/podman/podman.sock";
        SocketMode = "0660";
      };
      Install = {WantedBy = ["sockets.target"];};
    };
  };

  targets.genericLinux.enable = true;

  xdg = {
    enable = true;
    mimeApps = {
      defaultApplications = {"text/plain" = ["code_code.desktop"];};
      enable = true;
    };
  };
}
