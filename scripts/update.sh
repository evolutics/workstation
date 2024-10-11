#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

manage_packages() {
  sudo apt-get update

  local -r packages=(
    libvirt-daemon-system
    qemu-kvm
    rsnapshot
    steam

    # For Podman:
    golang-github-containers-common
    uidmap
  )
  sudo apt-get install -- "${packages[@]}"

  sudo snap install --classic code
  sudo snap install chromium
  sudo snap install gimp

  sudo apt-get dist-upgrade
  sudo snap refresh
}

configure_system_keyboard_layout() {
  sudo sed \
    --expression 's/^XKBLAYOUT=.*/XKBLAYOUT="de"/' \
    --expression 's/^XKBVARIANT=.*/XKBVARIANT="neo"/' \
    --in-place /etc/default/keyboard
}

configure_firefox() {
  sudo rsync --archive --mkpath --verbose configuration/firefox_policies.json \
    /etc/firefox/policies/policies.json
}

configure_backup() {
  sed "s/{{ user }}/${USER}/g" configuration/rsnapshot.conf \
    | sudo tee /etc/rsnapshot.conf >/dev/null

  for frequency in daily monthly weekly; do
    sed "s/{{ frequency }}/${frequency}/g" configuration/back_up.sh \
      | sudo tee "/etc/cron.${frequency}/back_up" >/dev/null
  done
}

upgrade_nix() {
  nix-env --install --file '<nixpkgs>' --attr nix cacert \
    -I nixpkgs=channel:nixpkgs-unstable
  sudo systemctl daemon-reload
  sudo systemctl restart nix-daemon
}

configure_home() {
  export NIX_CONFIG='experimental-features = flakes nix-command'
  # Try `home-manager switch` twice because it sometimes fails due to issue
  # https://github.com/nix-community/home-manager/issues/2033.
  # TODO: Remove workaround once issue is fixed.
  home-manager switch || home-manager switch
  unset NIX_CONFIG
}

manage_vs_code_extensions() {
  code \
    --install-extension bbenoist.nix \
    --install-extension eamodio.gitlens \
    --install-extension esbenp.prettier-vscode \
    --install-extension kamadorueda.alejandra \
    --install-extension ms-python.black-formatter \
    --install-extension rust-lang.rust-analyzer \
    --install-extension streetsidesoftware.code-spell-checker \
    --install-extension timonwong.shellcheck

  code --update-extensions
}

configure_vagrant() {
  vagrant plugin install vagrant-libvirt
  vagrant plugin update vagrant-libvirt
}

apply_optional_extras() {
  if [[ -f apply_extras.sh ]]; then
    ./apply_extras.sh
  fi
}

collect_garbage() {
  sudo apt-get autoremove
  sudo apt-get clean
  nix-collect-garbage --delete-older-than 30d --quiet

  podman ps # Workaround for Podman error "failed to reexec: Permission denied".
  podman system prune --all --filter until=720h --force
}

check_if_restart_required() {
  if [[ -f /var/run/reboot-required ]]; then
    notify-send 'System restart required'
  fi
}

main() {
  local -r script_folder="$(dirname "$(readlink --canonicalize "$0")")"
  cd "$(dirname "${script_folder}")"

  for function in \
    manage_packages \
    configure_system_keyboard_layout \
    configure_firefox \
    configure_backup \
    upgrade_nix \
    configure_home \
    manage_vs_code_extensions \
    configure_vagrant \
    apply_optional_extras \
    collect_garbage \
    check_if_restart_required; do
    printf '§\n\n'
    (
      set -o xtrace
      "${function}"
    )
    printf '\n\n'
  done
}

main "$@"
