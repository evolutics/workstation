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
    python3-venv
    rsnapshot
    steam
    uidmap # For Podman.
    usb-creator-gtk
    variety
    virtualbox
    virtualbox-dkms # For VirtualBox.
  )
  sudo apt-get install -- "${packages[@]}"
}

install_snaps() {
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
  sudo rsync --archive --mkpath --verbose files/firefox_policies.json \
    /etc/firefox/policies/policies.json
}

configure_rsnapshot() {
  sed "s/{{ USER }}/${USER}/g" templates/rsnapshot.conf \
    | sudo tee /etc/rsnapshot.conf >/dev/null
}

configure_anacron_jobs() {
  for frequency in daily monthly weekly; do
    sudo cp "files/cron.${frequency}/back_up.sh" \
      "/etc/cron.${frequency}/back_up"
  done
}

update_all_present_packages() {
  sudo apt-get dist-upgrade
}

clean_up_packages() {
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
    install_snaps \
    configure_keyboard_layouts \
    configure_firefox \
    configure_rsnapshot \
    configure_anacron_jobs \
    update_all_present_packages \
    clean_up_packages; do
    printf '§ %s\n\n' "${function}"
    "${function}"
    printf "\n\n"
  done
}

main "$@"