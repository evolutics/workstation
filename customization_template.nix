{
  email = "foo@example.com";
  extra_packages = pkgs:
    with pkgs; [
      chromium
      inkscape
      jetbrains.idea-community
      kazam
      nettools
      openvpn
      remmina
    ];
  name = "Foo Bar";
  username = "foo";
}