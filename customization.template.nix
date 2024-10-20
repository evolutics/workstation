rec {
  extra_files = {
    ".config/autostart/custom.desktop".text = ''
      [Desktop Entry]
      Exec=open "/media/${identity.username}"
      Name=Custom autostart
      Type=Application
    '';
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
  extra_packages = pkgs:
    with pkgs; [
      hello
    ];
  identity = {
    email = "foo@example.com";
    name = "Foo Bar";
    username = "foo";
  };
}
