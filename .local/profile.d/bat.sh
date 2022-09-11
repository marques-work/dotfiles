#!/bin/bash

if ! (return 0 2>/dev/null); then
  printf '\e[41;37;1m[FATAL] %s\e[0m\n' "You need to source $0 in your shell, not run it."
  exit 1
fi

if hash bat &> /dev/null; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi
