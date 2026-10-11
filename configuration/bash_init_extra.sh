#!/bin/bash

PROMPT_COMMAND=_update_current_bash_prompt

_update_current_bash_prompt() {
  local -r exit_status="$?"
  local -r terminal_title='\[\e]0;\w\a\]'

  if ((exit_status)); then
    local -r style='\e[7m' # Inverted.
  else
    local -r style='\e[1m' # Bold.
  fi

  local -r indicator='$'
  local -r style_reset='\e[0m'

  PS1="${terminal_title}\n\[${style}\]${indicator}\[${style_reset}\] "
}
