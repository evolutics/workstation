# Workstation

## Installation

1. Install [Ubuntu](https://ubuntu.com).
   - Applications installed to start with: change from "Default selection" to
     "Extended selection" for office tools, startup disk creator, etc.
   - Based on experience, it is safest not to install third-party software at
     first (default). If there are any issues, you can still change to another
     additional driver later.
   - Disk setup: to encrypt your system, it is easiest to do so by selecting
     this option now during the installation.
   - If the desktop freezes on first usage, try booting in recovery mode, then
     choose "dpkg: Repair broken packages" from the menu.
1. Restore the latest backup by running (without `--dry-run`)

   ```bash
   rsync --archive --dry-run --verbose \
     "/media/${USER}/backup/rsnapshot/daily.0/localhost/home/${USER}/data" ~
   ```

1. Install [Nix](https://nixos.org).
1. Install [Home Manager](https://nix-community.github.io/home-manager/).
1. Set up the workstation code with

   ```bash
   cd ~/.config/home-manager
   rm home.nix

   sudo apt install git
   git clone https://github.com/evolutics/workstation.git .
   sudo apt purge git

   cp customization.template.nix customization.nix
   cp configuration/autostart.template.sh configuration/autostart.sh
   ```

1. Customize as you wish with

   ```bash
   nano customization.nix
   diff customization.template.nix customization.nix
   nano configuration/autostart.sh
   ```

1. Then, run

   ```bash
   scripts/update.sh
   reboot
   ```

## Updating

```bash
cd ~/.config/home-manager
git pull

rm flake.lock
scripts/update.sh
```
