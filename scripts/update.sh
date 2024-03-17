#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

update_repositories_cache() {
  sudo apt-get update
}

purge_packages() {
  local -r packages=(
    mousepad
    numlockx # Purge due to possible issue with Neo 2 keyboard layout.
  )
  sudo apt-get purge -- "${packages[@]}"
}

install_packages() {
  local -r packages=(
    anacron
    containernetworking-plugins                      # For Podman.
    golang-github-containernetworking-plugin-dnsname # For Podman.
    libclang-dev
    libvirt-daemon-system
    qemu-kvm
    rsnapshot
    steam
    uidmap # For Podman.
    usb-creator-gtk
  )
  sudo apt-get install -- "${packages[@]}"

  sudo snap install \
    chromium
}

update_packages() {
  sudo apt-get dist-upgrade
  sudo snap refresh
}

configure_keyboard_layouts() {
  sudo sed \
    --expression 's/^XKBLAYOUT=.*/XKBLAYOUT="de,us"/' \
    --expression 's/^XKBVARIANT=.*/XKBVARIANT="neo,"/' \
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

configure_home() {
  # Try `home-manager switch` twice because it sometimes fails due to issue
  # https://github.com/nix-community/home-manager/issues/2033.
  # TODO: Remove workaround once issue is fixed.
  home-manager switch || home-manager switch
}

configure_vagrant() {
  vagrant plugin install vagrant-libvirt
  vagrant plugin update vagrant-libvirt
}

collect_garbage() {
  sudo apt-get autoremove
  sudo apt-get clean
  nix-collect-garbage --delete-older-than 30d --quiet
  docker system prune --all --filter until=720h --force
  podman system prune --all --filter until=720h --force
}

main() {
  local -r script_folder="$(dirname "$(readlink --canonicalize "$0")")"
  cd "$(dirname "${script_folder}")"

  for function in \
    update_repositories_cache \
    purge_packages \
    install_packages \
    update_packages \
    configure_keyboard_layouts \
    configure_firefox \
    configure_backup \
    configure_home \
    configure_vagrant \
    collect_garbage; do
    printf '§\n\n'
    (
      set -o xtrace
      "${function}"
    )
    printf '\n\n'
  done
}

main "$@"
