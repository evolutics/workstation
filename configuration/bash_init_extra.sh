#!/bin/bash

PROMPT_COMMAND=_update_current_bash_prompt

_update_current_bash_prompt() {
  local -r exit_status="$?"
  local -r terminal_title='\[\e]0;\w\a\]'

  local -r style_bold='\e[1m'
  local -r style_faint='\e[2m'
  local -r style_reset='\e[0m'
  local -r style_reverse_video='\e[7m'

  local path
  # Global: PS1 references it literally, so folder names are not parsed as PS1.
  if ! _prompt_git_folder="$(git rev-parse --show-prefix 2>/dev/null)"; then
    path='\w'
  elif [[ -z "${_prompt_git_folder}" ]]; then
    path=''
  else
    _prompt_git_folder="${_prompt_git_folder%/}"
    # shellcheck disable=SC2016
    path='${_prompt_git_folder}'
  fi

  local styled_path
  if [[ -z "${path}" ]]; then
    styled_path=''
  else
    styled_path="\[${style_faint}\]${path}\[${style_reset}\]"
  fi

  local indicator_styles="${style_bold}"
  if ((exit_status)); then
    indicator_styles+="${style_reverse_video}"
  fi
  local -r indicator="\[${indicator_styles}\]$\[${style_reset}\]"

  PS1="${terminal_title}\n${styled_path}${styled_path:+ }${indicator} "
}
