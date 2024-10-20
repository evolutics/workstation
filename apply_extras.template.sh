#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

if [[ -v IS_BEYOND_MINIMAL_UPDATE ]]; then
  sudo apt-get install rsnapshot

  sed "s/{{ user }}/${USER}/g" configuration/rsnapshot.conf \
    | sudo tee /etc/rsnapshot.conf >/dev/null

  for frequency in daily monthly weekly; do
    sed "s/{{ frequency }}/${frequency}/g" configuration/back_up.sh \
      | sudo tee "/etc/cron.${frequency}/back_up" >/dev/null
    sudo chmod +x "/etc/cron.${frequency}/back_up"
  done
fi
