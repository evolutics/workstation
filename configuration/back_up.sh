#!/bin/bash

set -o errexit -o nounset -o pipefail

/usr/bin/rsnapshot '{{ frequency }}'
