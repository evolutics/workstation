#!/bin/bash

export XDG_DATA_DIRS="$HOME/.nix-profile/share:$XDG_DATA_DIRS"

PS1='\[\e]0;\w\a$(_get_current_prompt_color_code)\]\w\[\e[0m\] • '

_get_current_prompt_color_code() {
  local -r seconds_per_day=86400
  local -r color_cycles_per_day=2
  local -r color_count=64

  local -r seconds_per_color=$((seconds_per_day / (color_cycles_per_day * color_count)))
  local -r color_index=$(((EPOCHSECONDS / seconds_per_color) % color_count))

  local xyz
  mapfile -t xyz < <(_cycle_through_4x4x4_cube "${color_index}")
  readonly xyz

  local -r r=$((xyz[0] + 1))
  local -r g=$((xyz[1] + 1))
  local -r b=$((xyz[2] + 1))
  local -r ansi_color_number=$((16 + 36 * r + 6 * g + b))

  printf '\e[38;5;%sm' "${ansi_color_number}"
}

_cycle_through_4x4x4_cube() {
  local -r index="$1"

  # Go through cube corners on this cycle (recursively):
  #
  #       4────────5
  #       │       ╱
  #     7━━━━━━━━6
  #     ┃ │
  #     ┃ 3────────2
  #     ┃         ╱
  #     0━━━━━━━━1
  #
  # The shifts guarantee that the cycle does not have "jumps": 2 consecutive
  # coordinate triples (x, y, z) always differ by exactly 1 in terms of 1-norm.
  # For example, the first 2 subcubes (0 and 1 above) are visited on this path:
  #
  #       ┌──────7 ┄┄┄┄ 8──────
  #       │                   ╱
  #     ┏━━━━━━0      ┏━━━━━━
  #     ┃ └──────     ┃ 15─────
  #     ┃       ╱     ┃       ╱
  #     ┗━━━━━━       ┗━━━━━━

  local -r cube_cycle=(000 100 110 010 011 111 101 001)
  local -r cycle_shifts=(6 4 0 6 2 0 4 2)

  local -r high_octal_digit=$((index / 8))
  local -r low_octal_digit=$((index % 8))

  local -r high_xyz=${cube_cycle[$high_octal_digit]}
  local -r shift=${cycle_shifts[$high_octal_digit]}
  local -r low_xyz=${cube_cycle[$(((low_octal_digit + shift) % 8))]}

  local -r x=$((${high_xyz:0:1} << 1 | ${low_xyz:0:1}))
  local -r y=$((${high_xyz:1:1} << 1 | ${low_xyz:1:1}))
  local -r z=$((${high_xyz:2:1} << 1 | ${low_xyz:2:1}))

  printf '%s\n%s\n%s\n' "${x}" "${y}" "${z}"
}
