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

1. Set up the workstation code with

   ```bash
   mkdir ~/.config/home-manager
   cd ~/.config/home-manager

   sudo apt install git
   git clone https://github.com/evolutics/workstation.git .

   cp customization.template.nix customization.nix
   ```

1. Customize as you wish with

   ```bash
   nano customization.nix
   diff customization.template.nix customization.nix

   nano apply_extras.sh
   chmod +x apply_extras.sh
   ```

1. Finish with

   ```bash
   scripts/apply.sh
   sudo apt purge git
   reboot
   ```

## Updating

A minimal update is auto-run for security. To apply other changes, too, run

```bash
cd ~/.config/home-manager
git pull
scripts/apply.sh
```

Update code marked with "update-worthy" about every 6 months.

## Developing

### Deciding which package source to use

The OS may already install a tool by default (e.g., Firefox). Otherwise:

- **Ubuntu APT (no PPAs)** for system-wide tool configuration.
- **Snap Store** if it is tool's official distribution channel (e.g., VS Code).
- **Nixpkgs with Home Manager** for many developer tools.

### Desktop settings as code

Many settings are stored in your dconf database. To see what keys to set to what
values, keep `dconf watch /` running while you change a setting via UI.
