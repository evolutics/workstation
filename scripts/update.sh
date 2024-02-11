#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

update_repositories_cache() {
  sudo apt-get update
}

remove_packages() {
  local -r packages=(
    mousepad
    numlockx # Remove due to possible issue with Neo 2 keyboard layout.
  )
  sudo apt-get remove -- "${packages[@]}"
}

install_packages() {
  local -r packages=(
    anacron
    containernetworking-plugins                      # For Podman.
    golang-github-containernetworking-plugin-dnsname # For Podman.
    libclang-dev
    linux-headers-generic # For VirtualBox.
    rsnapshot
    steam
    uidmap # For Podman.
    usb-creator-gtk
    variety
    virtualbox
    virtualbox-dkms # For VirtualBox.
  )
  sudo apt-get install -- "${packages[@]}"

  sudo snap install \
    chromium
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
  sed "s/{{ USER }}/${USER}/g" configuration/rsnapshot.conf \
    | sudo tee /etc/rsnapshot.conf >/dev/null

  for frequency in daily monthly weekly; do
    sed "s/{{ frequency }}/${frequency}/g" configuration/back_up.sh \
      | sudo tee "/etc/cron.${frequency}/back_up" >/dev/null
  done
}

update_all_present_packages() {
  sudo apt-get dist-upgrade
}

collect_garbage() {
  sudo apt-get autoclean
  sudo apt-get autoremove
}

main() {
  local -r script_folder="$(dirname "$(readlink --canonicalize "$0")")"
  cd "$(dirname "${script_folder}")"

  for function in \
    update_repositories_cache \
    remove_packages \
    install_packages \
    configure_keyboard_layouts \
    configure_firefox \
    configure_backup \
    update_all_present_packages \
    collect_garbage; do
    printf '§ %s\n\n' "${function}"
    "${function}"
    printf "\n\n"
  done
}

main "$@"
