{
  extras = {
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
