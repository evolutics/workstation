{
  extra_files = {
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
  identity = {
    email = "foo@example.com";
    name = "Foo Bar";
    username = "foo";
  };
}
