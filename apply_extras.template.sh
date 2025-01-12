#!/bin/bash

set -o errexit -o nounset -o pipefail

if [[ -v IS_BEYOND_MINIMAL_UPDATE ]]; then
  sudo apt-get install -- \
    rsnapshot \
    steam

  sed "s/{{ user }}/${USER}/g" configuration/rsnapshot.conf \
    | sudo tee /etc/rsnapshot.conf >/dev/null

  for frequency in daily monthly weekly; do
    sed --expression "s/{{ frequency }}/${frequency}/g" \
      --expression "s/{{ user }}/${USER}/g" configuration/back_up.sh \
      | sudo tee "/etc/cron.${frequency}/back_up" >/dev/null
    sudo chmod +x "/etc/cron.${frequency}/back_up"
  done
fi
