#!/bin/bash

set -o errexit -o nounset -o pipefail

if [[ -v IS_BEYOND_MINIMAL_UPDATE ]]; then
  sudo apt-get install -- \
    musl-tools \
    rsnapshot \
    steam

  sed "s/{{ user }}/${USER}/g" configuration/rsnapshot.conf \
    | sudo tee /etc/rsnapshot.conf >/dev/null

  for frequency in daily monthly weekly; do
    sudo cp configuration/back_up.sh "/etc/cron.${frequency}/back_up"
  done

  sudo snap install xournalpp
fi
