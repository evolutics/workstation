1. Install [Xubuntu](https://xubuntu.org).
1. Install [Nix](https://nixos.org).
1. Install [Home Manager](https://nix-community.github.io/home-manager/).
1. Interactively run

   ```bash
   sudo apt install git

   cd ~/.config/nixpkgs
   rm home.nix
   git clone git@github.com:evolutics/managed-home.git .

   cp customization_template.nix customization.nix
   # Customize as you wish.
   nano customization.nix

   home-manager switch

   folder="$(mktemp --directory)"
   cd "${folder}"
   git clone git@github.com:evolutics/workstation.git .
   ansible-playbook --ask-become-pass playbook.yml
   cd -
   rm --force --recursive -- "${folder}"

   # Do this in interactive shell to accept license.
   sudo apt install virtualbox-ext-pack

   reboot
   ```

1. Every time you wish to **update**, run

   ```bash
   cd ~/.config/nixpkgs
   git pull
   nix-channel --update
   home-manager switch

   ansible-playbook --ask-become-pass playbook.yml
   ```
