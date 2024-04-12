#!/bin/bash
# vim: sts=2 sw=2 et

# by default, create files with minimal permissions
umask 0077

# If not running interactively, don't do anything
case $- in
  *i*) ;;
  *) return;;
esac

# STFU about zsh
export BASH_SILENCE_DEPRECATION_WARNING="1"

export COPYFILE_DISABLE="1"
export COPY_EXTENDED_ATTRIBUTES_DISABLE="1"

#     /\ .__       .__  __        /\
#    / / |__| ____ |__|/  |_     / /
#   / /  |  |/    \|  \   __\   / /
#  / /   |  |   |  \  ||  |    / /
# / /    |__|___|  /__||__|   / /
# \/             \/           \/

function __init() {
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  local _pfx="$(type brew &> /dev/null && brew --prefix || echo "/usr/local")"

  __init_git
  __init_ssh
  __init_version_managers
  __init_path_additions "$_pfx"
  __init_completions "$_pfx"
  __init_prompt
  __defun_motd

  for init in "$HOME"/.{aliases,functions,key-bindings}; do
    [ -f "$init" ] && source "$init"
  done

  # load extensions from ~/.local/profile.d
  if [ -d ~/.local/profile.d ]; then
    for init in ~/.local/profile.d/*; do
      if [ -f "$init" ]; then
        source "$init"
      fi
    done
  fi

  if command -v mvim &> /dev/null; then
    export VISUAL="mvim -f"
    export EDITOR="mvim -f"
  else
    export EDITOR="vim"
  fi

  # cleanup scope
  unset __init_git
  unset __init_ssh
  unset __init_version_managers
  unset __init_path_additions
  unset __init_completions
  unset __init_prompt
  unset __defun_motd
  unset __init

  if [ -d ~/.ansi ] && ls ~/.ansi/* &> /dev/null; then
    motd
  fi
}

#     /\                __  .__                  /\
#    / /  ___________ _/  |_|  |__   ______     / /
#   / /   \____ \__  \\   __\  |  \ /  ___/    / /
#  / /    |  |_> > __ \|  | |   Y  \\___ \    / /
# / /     |   __(____  /__| |___|  /____  >  / /
# \/      |__|       \/          \/     \/   \/

function __init_path_additions() {
  local _pfx="${1:-/usr/local}"

  if [ -d "$_pfx/sbin" ]; then
    export PATH="$_pfx/sbin:$PATH"
  fi

  if type go &> /dev/null; then
    export PATH="$(go env GOPATH)/bin:$PATH"
  fi

  if [ -r "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
  fi

  if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
  fi

  if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
  fi
}

#     /\     .___             __                .__               /\
#    / /   __| _/_______  ___/  |_  ____   ____ |  |   ______    / /
#   / /   / __ |/ __ \  \/ /\   __\/  _ \ /  _ \|  |  /  ___/   / /
#  / /   / /_/ \  ___/\   /  |  | (  <_> |  <_> )  |__\___ \   / /
# / /    \____ |\___  >\_/   |__|  \____/ \____/|____/____  > / /
# \/          \/    \/                                    \/  \/

function __init_git() {
  export GIT_PS1_SHOWCOLORHINTS="true"
  export GIT_PS1_SHOWDIRTYSTATE="true"
  export GIT_PS1_SHOWUPSTREAM="auto"

  if type mvim &> /dev/null; then
    export GIT_EDITOR="mvim -f"
  fi

  alias g="git"
}

function __init_ssh() {
  eval "$(ssh-agent -s)"
  trap "ssh-agent -k" EXIT
}

function __init_version_managers() {
  if type direnv &> /dev/null; then
    eval "$(direnv hook bash)"
  fi

  if [ -r "$HOME/.asdf/asdf.sh" ]; then
    . "$HOME/.asdf/asdf.sh"
    . "$HOME/.asdf/completions/asdf.bash"

    if [ -r "$HOME/.asdf/plugins/java/set-java-home.bash" ]; then
      . "$HOME/.asdf/plugins/java/set-java-home.bash"
    fi
  elif type brew &> /dev/null; then
    # homebrew
    local _pfx="$(brew --prefix)"

    if [ -r "$_pfx/opt/asdf/libexec/asdf.sh" ]; then
      . "$_pfx/opt/asdf/libexec/asdf.sh"

      if [ -r "$HOME/.asdf/plugins/java/set-java-home.bash" ]; then
        . "$HOME/.asdf/plugins/java/set-java-home.bash"
      fi
    fi
  fi
}

#     /\                             .__          __  .__                           /\
#    / /   ____  ____   _____ ______ |  |   _____/  |_|__| ____   ____   ______    / /
#   / /  _/ ___\/  _ \ /     \\____ \|  | _/ __ \   __\  |/  _ \ /    \ /  ___/   / /
#  / /   \  \__(  <_> )  Y Y  \  |_> >  |_\  ___/|  | |  (  <_> )   |  \\___ \   / /
# / /     \___  >____/|__|_|  /   __/|____/\___  >__| |__|\____/|___|  /____  > / /
# \/          \/            \/|__|             \/                    \/     \/  \/

function __init_completions() {
  local _pfx="${1:-/usr/local}"

  if [ -r "$_pfx/etc/profile.d/bash_completion.sh" ]; then
    . "$_pfx/etc/profile.d/bash_completion.sh"
  fi

  if [ -d "$_pfx/etc/bash_completion.d" ]; then
    for init in "$_pfx"/etc/bash_completion.d/*; do
      if [ "$(basename "$init")" = "wg" ] || [ "$(basename "$init")" = "wg-quick" ]; then
        continue
      fi

      . "$init"
    done
  elif [ -r /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion

    if ! type __git_complete &> /dev/null && [ -r /usr/share/bash-completion/completions/git ]; then
      . /usr/share/bash-completion/completions/git
    fi
  elif [ -r /etc/bash_completion ]; then
    . /etc/bash_completion
  fi

  if type __git_complete &> /dev/null && [ "alias g='git'" = "$(alias g 2> /dev/null)" ]; then
    __git_complete g __git_main
  fi
}

#     /\                                     __        /\
#    / / _____________  ____   _____ _______/  |_     / /
#   / /  \____ \_  __ \/  _ \ /     \\____ \   __\   / /
#  / /   |  |_> >  | \(  <_> )  Y Y  \  |_> >  |    / /
# / /    |   __/|__|   \____/|__|_|  /   __/|__|   / /
# \/     |__|                      \/|__|          \/

function __init_prompt() {
  local gitprompt='__git_ps1 "\h:\W" " \u\\\$ "'

  if type __show_env_name &> /dev/null; then
    PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}__show_env_name"
  fi

  if ! [[ "${PROMPT_COMMAND:-}" =~ __git_ps1 ]]; then
    PROMPT_COMMAND="${gitprompt}${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
  fi
}

function __show_env_name() {
  local envname="${ENVIRONMENT:-${ENVNAME:-""}}"
  local orig="$PS1"

  if [ -n "$envname" ]; then
    case "$envname" in
      prod|prd|production)
        local envtag="$(printf "\[\e[31;5;1m\]::: 🚨 \[\e[0;31;1m\]%s\[\e[31;5;1m\] 🚨 :::\[\e[0m\]" "$envname")"
        ;;
      preprod|ppd|staging|stage|uat)
        local envtag="$(printf "\[\e[35;1m\]::: 💡 %s 💡 :::\[\e[0m\]" "$envname")"
        ;;
      nonprod|npe|qa)
        local envtag="$(printf "\[\e[36;1m\]%s\[\e[0m\]" "$envname")"
        ;;
      dev|ci|int)
        local envtag="$(printf "\[\e[32;1m\]%s\[\e[0m\]" "$envname")"
        ;;
      *)
        local envtag="$(printf "\[\e[37;1m\]%s\[\e[0m\]" "$envname")"
        ;;
    esac

    export PS1="$(printf "❮ \[\e[37;1m\]ENV\[\e[0m\] » %s ❯ %s" "$envtag" "$orig")"
  else
    export PS1="$orig"
  fi
}

#     /\                      .__.__                   __      .___     /\
#    / / _____    ______ ____ |__|__|    _____   _____/  |_  __| _/    / /
#   / /  \__  \  /  ___// ___\|  |  |   /     \ /  _ \   __\/ __ |    / /
#  / /    / __ \_\___ \\  \___|  |  |  |  Y Y  (  <_> )  | / /_/ |   / /
# / /    (____  /____  >\___  >__|__|  |__|_|  /\____/|__| \____ |  / /
# \/          \/     \/     \/               \/                 \/  \/

function __defun_motd() {
  if command -v cp437 &> /dev/null; then
    function ansicat { cp437 cat "$@"; }
  else
    function ansicat { iconv -c -f 437 -t utf-8 "$@"; }
  fi

  function motd {
    local art="${1:-$(ls ~/.ansi/* | sort -R | tail -1)}"
    ansicat "$art"
    tput sgr0
    printf '\n\n'
  }
}

#     /\      /\                         .__       .__  __
#    / /     / /  _______ __ __  ____    |__| ____ |__|/  |_
#   / /     / /   \_  __ \  |  \/    \   |  |/    \|  \   __\
#  / /     / /     |  | \/  |  /   |  \  |  |   |  \  ||  |
# / /     / /      |__|  |____/|___|  /  |__|___|  /__||__|
# \/      \/                        \/           \/

__init
