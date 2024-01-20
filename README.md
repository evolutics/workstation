1. Install [Xubuntu](https://xubuntu.org).
   - Based on experience, it is safest not to install third-party software at
     first (default). If there are any issues, you can still change to another
     additional driver later.
   - If you like to encrypt your system, it is easiest to do so by selecting
     this option now during the installation.
   - If the desktop freezes on first usage, try booting in recovery mode, then
     choose "dpkg: Repair broken packages" from the menu.
1. Install [Nix](https://nixos.org).
1. Install [Home Manager](https://nix-community.github.io/home-manager/).
1. As a one time setup, run

   ```bash
   sudo apt install git

   cd ~/.config/home-manager
   rm home.nix
   git clone https://github.com/evolutics/workstation.git .
   cp customization.template.nix customization.nix
   cp scripts/autostart.template.sh scripts/autostart.sh
   ```

1. Then, run

   ```bash
   cd ~/.config/home-manager
   git pull
   sudo apt remove git

   # Customize as you wish.
   nano customization.nix
   diff customization.template.nix customization.nix
   nano scripts/autostart.sh

   rm flake.lock
   home-manager switch
   ansible-playbook --ask-become-pass playbook.yml
   snap refresh

   reboot
   ```

   Repeat this step whenever you wish to **update**.
