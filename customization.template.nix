{
  extra = {
    files = {
      ".config/containers/registries.conf" = ''
        [[registry]]
        location = "docker.io"
        [[registry.mirror]]
        location = "example.com"
      '';
      ".npmrc" = ''
        registry=https://example.com
      '';
    };
    packages = pkgs:
      with pkgs; [
        inkscape
        kazam
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
