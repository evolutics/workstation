#!/bin/bash

set -o errexit -o nounset -o pipefail

if [[ -v IS_BEYOND_MINIMAL_UPDATE ]]; then
  sudo apt-get install -- \
    rsnapshot \
    steam

  readonly sed_script="s|{{ rsnapshot_log }}|/var/log/rsnapshot.log|g
s/{{ user }}/${USER}/g"

  echo "${sed_script}" \
    | sed --file - configuration/rsnapshot.conf \
    | sudo tee /etc/rsnapshot.conf >/dev/null

  for frequency in daily monthly weekly; do
    echo "${sed_script}" \
      | sed --expression "s/{{ frequency }}/${frequency}/g" --file - \
        configuration/back_up.sh \
      | sudo tee "/etc/cron.${frequency}/back_up" >/dev/null
    sudo chmod +x "/etc/cron.${frequency}/back_up"
  done
fi
