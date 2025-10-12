#!/bin/bash

set -o errexit -o nounset -o pipefail

notify_users() {
  local -r message="$1"
  readarray -t users < <(who | awk '{print $1}' | sort --uniq)
  for user in "${users[@]}"; do
    su "${user}" --command "notify-send '${message}'"
  done
}

main() {
  cd -- "$(dirname -- "$0")"
  local -r frequency="${PWD##*.}"

  if /usr/bin/rsnapshot "${frequency}"; then
    if (("${RANDOM}" % 7 == 0)); then
      notify_users "Backup ${frequency} succeeded"
    fi
  else
    notify_users "Backup ${frequency} failed, see: /var/log/rsnapshot.log"
    exit 1
  fi
}

main "$@"
