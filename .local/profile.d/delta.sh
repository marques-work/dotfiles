#!/bin/bash

if ! (return 0 2>/dev/null); then
  printf '\e[41;37;1m[FATAL] %s\e[0m\n' "You need to source $0 in your shell, not run it."
  exit 1
fi

if hash delta &> /dev/null; then
  alias gx='DELTA_FEATURES="+side-by-side" git'
  __git_complete gx __git_main
fi
