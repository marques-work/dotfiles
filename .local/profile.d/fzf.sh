#!/bin/bash

if ! (return 0 2>/dev/null); then
  printf '\e[41;37;1m[FATAL] %s\e[0m\n' "You need to source $0 in your shell, not run it."
  exit 1
fi

if { ! hash fzf &> /dev/null || ! type _fzf_complete &> /dev/null; } && [ -f ~/.fzf.bash ]; then
  # shellcheck disable=SC1090
  source ~/.fzf.bash
  hash -r
fi

if hash fzf &> /dev/null; then
  export FZF_CTRL_T_OPTS="--select-1 --exit-0"

  if hash fd &> /dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix'
  fi

  if hash exa &> /dev/null; then
    export FZF_ALT_C_OPTS="--preview 'exa --tree {} | head -500'"
  fi

  if hash bat &> /dev/null; then
    export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}' $FZF_CTRL_T_OPTS"
  fi
fi
