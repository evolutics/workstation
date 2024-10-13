#!/bin/bash

export XDG_DATA_DIRS="${HOME}/.nix-profile/share:${XDG_DATA_DIRS}"

PROMPT_COMMAND=_update_current_bash_prompt

_update_current_bash_prompt() {
  local -r exit_status="$?"
  local -r terminal_title='\[\e]0;\w\a\]'

  local -r seconds_per_day=86400
  local -r color_cycles_per_day=2
  local -r hue_count=768

  local -r seconds_per_color="$((seconds_per_day / (color_cycles_per_day * hue_count)))"
  local -r hue="$(((EPOCHSECONDS / seconds_per_color) % hue_count))"

  local -ir saturation=255 value=255
  local -r rgb="$(_integer_hsv_to_rgb "${hue}" "${saturation}" "${value}")"

  local -r color_code="\e[38;2;${rgb}m"
  local -r color_reset='\e[0m'

  local separator
  if [[ "${exit_status}" -eq 0 ]]; then
    separator=' • '
  else
    separator=' ◘ '
  fi
  readonly separator

  PS1="${terminal_title}\[${color_code}\]\w\[${color_reset}\]${separator}"
}

# HSV to RGB color for integers 0 ≤ h < 3 p; 0 ≤ s, v, r, g, b < p; p = 256.
_integer_hsv_to_rgb() {
  # See https://en.wikipedia.org/wiki/HSL_and_HSV#HSV_to_RGB for the fractional
  # formulae with variables H, S, V; R, G, B; C, H', X, R₁, G₁, B₁, m.
  #
  # Let h = 3 p H / 2π, s = q S, v = q V; q = p - 1.
  #
  # We need (r, g, b) = q (R, G, B). Thus,
  #
  #   (r, g, b) = (q R₁ + q m, q G₁ + q m, q B₁ + q m)
  #   q m = q V - q C = v - q C
  #   q C = q V S = v s / q
  #   H' = 2 h / p
  #   H' mod 2 = (2 h / p) mod 2 = 2 (h mod p) / p
  #   q X = q C (1 - |H' mod 2 - 1|) = q C - |2 q C (h mod p) / p - q C|.

  local -ir h="$1" s="$2" v="$3"

  local -ir p=256
  ((h >= 0 && h < 3 * p && s >= 0 && s < p && v >= 0 && v < p))

  local -ir q_c="$(((v * s) / (p - 1)))"
  local -ir y="$(((2 * q_c * (h % p)) / p - q_c))"
  local -ir abs_y="${y#-}"
  local -ir q_x="$((q_c - abs_y))"

  case "$(((2 * h) / p))" in
    0) local -ir rgb1=("${q_c}" "${q_x}" 0) ;;
    1) local -ir rgb1=("${q_x}" "${q_c}" 0) ;;
    2) local -ir rgb1=(0 "${q_c}" "${q_x}") ;;
    3) local -ir rgb1=(0 "${q_x}" "${q_c}") ;;
    4) local -ir rgb1=("${q_x}" 0 "${q_c}") ;;
    5) local -ir rgb1=("${q_c}" 0 "${q_x}") ;;
  esac

  local -ir q_m="$((q_m = v - q_c))"
  echo "$((rgb1[0] + q_m));$((rgb1[1] + q_m));$((rgb1[2] + q_m))"
}
