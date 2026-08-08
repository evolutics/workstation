#!/bin/bash

set -o errexit -o nounset -o pipefail

is_full_apply_due() {
  local -r due_period="${1:-7 days}"

  local last_full_apply_time
  last_full_apply_time="$(tail --lines 1 full_apply_times 2>/dev/null || true)"
  local cutoff_time
  cutoff_time="$(date --date="${due_period} ago" --iso-8601=seconds || exit)"

  [[ "${last_full_apply_time}" < "${cutoff_time}" ]]
}

manage_packages() {
  if [[ -v IS_FULL_APPLY ]]; then
    sudo apt-get update
    local -r packages=(
      libvirt-daemon-system
      qemu-kvm
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
  if [[ -v IS_FULL_APPLY ]]; then
    sudo sed \
      --expression 's/^XKBLAYOUT=.*/XKBLAYOUT="de"/' \
      --expression 's/^XKBVARIANT=.*/XKBVARIANT="neo"/' \
      --in-place /etc/default/keyboard
  fi
}

configure_firefox() {
  if [[ -v IS_FULL_APPLY ]]; then
    sudo rsync --archive --mkpath --verbose \
      configuration/firefox_policies.json /etc/firefox/policies/policies.json
  fi
}

manage_nix() {
  export NIX_CONFIG='experimental-features = flakes nix-command'

  if [[ -v IS_FULL_APPLY ]]; then
    nix upgrade-nix
  fi

  nix flake update
  nix run home-manager/release-26.05 -- --flake path:. switch # Update-worthy.

  unset NIX_CONFIG
}

manage_vs_code_extensions() {
  if [[ -v IS_FULL_APPLY ]]; then
    code --force \
      --install-extension bierner.markdown-mermaid \
      --install-extension charliermarsh.ruff \
      --install-extension eamodio.gitlens \
      --install-extension esbenp.prettier-vscode \
      --install-extension ms-python.python \
      --install-extension ms-vscode-remote.remote-containers \
      --install-extension streetsidesoftware.code-spell-checker \
      --install-extension timonwong.shellcheck
  fi
}

configure_vagrant() {
  if [[ -v IS_FULL_APPLY ]]; then
    vagrant plugin install vagrant-libvirt
  fi
  vagrant plugin update
}

apply_extras() {
  ./apply_extras.sh
}

collect_garbage() {
  if [[ -v IS_FULL_APPLY ]]; then
    sudo apt-get autopurge
    sudo apt-get clean
    nix-collect-garbage --delete-older-than 30d --quiet
    podman system prune --all --filter until=720h --force
  fi
}

main() {
  cd -- "$(dirname -- "$0")/.."

  if is_full_apply_due "$@"; then
    export IS_FULL_APPLY=
  else
    unset IS_FULL_APPLY
  fi

  for function in \
    manage_packages \
    configure_system_keyboard_layout \
    configure_firefox \
    manage_nix \
    manage_vs_code_extensions \
    configure_vagrant \
    apply_extras \
    collect_garbage; do
    printf '\n%s  %s\n\n' "${IS_FULL_APPLY+●}${IS_FULL_APPLY-◐}" "${function}"
    (
      set -o xtrace
      "${function}"
    )
    printf '\n\n'
  done

  if [[ -v IS_FULL_APPLY ]]; then
    date --iso-8601=seconds >>full_apply_times
  fi
}

main "$@"
