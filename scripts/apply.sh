#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

manage_packages() {
  if [[ -v IS_BEYOND_MINIMAL_UPDATE ]]; then
    sudo apt-get update
    local -r packages=(
      libvirt-daemon-system
      qemu-kvm
      rsnapshot
      steam
      virtiofsd
      # For Podman:
      golang-github-containers-common
      uidmap
    )
    sudo apt-get install -- "${packages[@]}"

    sudo snap install chromium
    sudo snap install --classic code
  fi
}

configure_system_keyboard_layout() {
  if [[ -v IS_BEYOND_MINIMAL_UPDATE ]]; then
    sudo sed \
      --expression 's/^XKBLAYOUT=.*/XKBLAYOUT="de"/' \
      --expression 's/^XKBVARIANT=.*/XKBVARIANT="neo"/' \
      --in-place /etc/default/keyboard
  fi
}

configure_firefox() {
  if [[ -v IS_BEYOND_MINIMAL_UPDATE ]]; then
    sudo rsync --archive --mkpath --verbose \
      configuration/firefox_policies.json /etc/firefox/policies/policies.json
  fi
}

configure_backup() {
  if [[ -v IS_BEYOND_MINIMAL_UPDATE ]]; then
    sed "s/{{ user }}/${USER}/g" configuration/rsnapshot.conf \
      | sudo tee /etc/rsnapshot.conf >/dev/null

    for frequency in daily monthly weekly; do
      sed "s/{{ frequency }}/${frequency}/g" configuration/back_up.sh \
        | sudo tee "/etc/cron.${frequency}/back_up" >/dev/null
      sudo chmod +x "/etc/cron.${frequency}/back_up"
    done
  fi
}

manage_nix() {
  nix upgrade-nix

  export NIX_CONFIG='experimental-features = flakes nix-command'
  nix flake update
  # Retry due to https://github.com/nix-community/home-manager/issues/2033.
  # TODO: Remove workaround once issue is fixed.
  retry_once nix run home-manager/release-24.05 -- switch # Update-worthy.
  unset NIX_CONFIG
}

manage_vs_code_extensions() {
  if [[ -v IS_BEYOND_MINIMAL_UPDATE ]]; then
    code \
      --install-extension bbenoist.nix \
      --install-extension eamodio.gitlens \
      --install-extension esbenp.prettier-vscode \
      --install-extension kamadorueda.alejandra \
      --install-extension ms-python.black-formatter \
      --install-extension rust-lang.rust-analyzer \
      --install-extension streetsidesoftware.code-spell-checker \
      --install-extension timonwong.shellcheck
  fi
}

configure_vagrant() {
  if [[ -v IS_BEYOND_MINIMAL_UPDATE ]]; then
    vagrant plugin install vagrant-libvirt
  fi
  vagrant plugin update
}

apply_optional_extras() {
  if [[ -f apply_extras.sh ]]; then
    ./apply_extras.sh
  fi
}

collect_garbage() {
  if [[ -v IS_BEYOND_MINIMAL_UPDATE ]]; then
    sudo apt-get autopurge
    sudo apt-get clean
    nix-collect-garbage --delete-older-than 30d --quiet
    # Retry works around Podman error "failed to reexec: Permission denied".
    retry_once podman system prune --all --filter until=720h --force
  fi
}

retry_once() {
  "$@" || "$@"
}

main() {
  local -r script_folder="$(dirname "$(readlink --canonicalize "$0")")"
  cd "$(dirname "${script_folder}")"

  if (( $# == 0 )); then
    export IS_BEYOND_MINIMAL_UPDATE=
  else
    unset IS_BEYOND_MINIMAL_UPDATE
  fi

  for function in \
    manage_packages \
    configure_system_keyboard_layout \
    configure_firefox \
    configure_backup \
    manage_nix \
    manage_vs_code_extensions \
    configure_vagrant \
    apply_optional_extras \
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
