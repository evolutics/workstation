{
  extra = {
    files = {
      ".config/containers/registries.conf".text = ''
        [[registry]]
        location = "docker.io"
        [[registry.mirror]]
        location = "example.com"
      '';
      ".npmrc".text = ''
        registry=https://example.com
      '';
    };
    packages = pkgs:
      with pkgs; [
        inkscape
        openvpn
      ];
  };
  identity = {
    email = "foo@example.com";
    name = "Foo Bar";
    username = "foo";
  };
}
