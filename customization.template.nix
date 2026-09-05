rec {
  extra_files = {
    ".config/autostart/mount_backup_drive.desktop".text = ''
      [Desktop Entry]
      Exec=gio mount --device /dev/sdb1
      Name=Mount backup drive
      Terminal=true
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
