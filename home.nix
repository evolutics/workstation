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
        ".config/autostart/custom.desktop".text = ''
          [Desktop Entry]
          Exec=${customization.autostart_exec}
          Name=Custom autostart
          Type=Application
        '';
        ".config/Code/User/settings.json".text = builtins.toJSON {
          "[python]" = {
            "editor.defaultFormatter" = "ms-python.black-formatter";
          };
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
        git-absorb
        haskellPackages.hadolint
        jq
        kubectl
        minikube
        nodePackages.prettier
        pdftk
        podman
        rustup
        skaffold
        texliveMedium
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

  targets.genericLinux.enable = true;

  xdg = {
    enable = true;
    mimeApps = {
      defaultApplications = {"text/plain" = ["code_code.desktop"];};
      enable = true;
    };
  };
}
