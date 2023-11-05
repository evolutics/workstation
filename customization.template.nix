{
  extra = {
    files = {
      ".config/containers/registries.conf" = ''
        [[registry]]
        location = "docker.io"
        [[registry.mirror]]
        location = "example.com"
      '';
      ".docker/daemon.json" = builtins.toJSON {
        ip = "127.0.0.1";
        registry-mirrors = ["https://example.com"];
      };
      ".npmrc" = ''
        registry=https://example.com
      '';
    };
    packages = pkgs:
      with pkgs; [
        chromium
        inkscape
        kazam
        nettools
        openvpn
        remmina
        terraform
      ];
    vscodeExtensions = pkgs:
      with pkgs.vscode-extensions; [
      ];
  };
  identity = {
    email = "foo@example.com";
    name = "Foo Bar";
    username = "foo";
  };
}
