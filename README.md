# Workstation

## Installation

1. Install [Ubuntu](https://ubuntu.com).

   - Applications: switch from default to the extended selection of apps
     installed to start with for office tools, startup disk creator, etc.
   - Proprietary software: based on experience, do not to install third-party
     drivers at first (default); in case of issues you can still do so later.
   - Disk setup: select encryption as it is easiest to introduce now.
   - Troubleshooting: if the desktop freezes on first usage, try booting in
     recovery mode, then choose "dpkg: Repair broken packages" from the menu.

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
   nano apply_extras.sh
   ```

1. Finally, apply with

   ```bash
   scripts/apply.sh
   reboot
   ```

## Updating

```bash
cd ~/.config/home-manager
git pull

rm flake.lock
scripts/apply.sh
```
