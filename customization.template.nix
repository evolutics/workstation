{
  extra = {
    files = {
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
        gradle
        inkscape
        jetbrains.idea-community
        kazam
        nettools
        openvpn
        remmina
      ];
  };
  identity = {
    email = "foo@example.com";
    name = "Foo Bar";
    username = "foo";
  };
}
