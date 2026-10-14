#!/bin/bash

PROMPT_COMMAND=_update_current_bash_prompt

_update_current_bash_prompt() {
  local -r exit_status="$?"
  local -r terminal_title='\[\e]0;\w\a\]'

  local style="\e[1" # Bold.

  if ((exit_status)); then
    style+=";7" # Reverse video.
  fi

  local git_folder
  if git_folder=$(git rev-parse --show-prefix 2>/dev/null); then
    if [[ -n "${git_folder}" ]]; then
      style+=";4" # Underlined.
    fi
  else
    style+=";2" # Faint.
  fi

  style+="m"

  local -r indicator='$'
  local -r style_reset='\e[0m'

  PS1="${terminal_title}\n\[${style}\]${indicator}\[${style_reset}\] "
}
