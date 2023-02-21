1. Install [Xubuntu](https://xubuntu.org).
   - Based on experience, it is safest not to install third-party software at
     first (default). If there are any issues, you can still change to another
     additional driver later.
   - If you like to encrypt your system, it is easiest to do so by selecting
     this option now during the installation.
1. Install [Nix](https://nixos.org).
1. Install [Home Manager](https://nix-community.github.io/home-manager/).
1. As a one time setup, run

   ```bash
   sudo apt install git

   cd ~/.config/nixpkgs
   rm home.nix
   git clone git@github.com:evolutics/workstation.git .
   cp customization.template.nix customization.nix
   ```

1. Then, run

   ```bash
   cd ~/.config/nixpkgs
   git pull
   sudo apt remove git

   # Customize as you wish.
   nano customization.nix
   diff customization.template.nix customization.nix

   nix-channel --update
   home-manager switch
   ansible-playbook --ask-become-pass playbook.yml
   snap refresh

   reboot
   ```

   Repeat this step whenever you wish to **update**.
