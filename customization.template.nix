rec {
  autostart_exec = "open \"/media/${identity.username}\"";
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
