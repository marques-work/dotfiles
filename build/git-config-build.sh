#!/bin/bash
# vim: sts=2 sw=2 et

set -euo pipefail

function _build_gitconfig() {
  _gcfg alias.ap add\ --patch
  _gcfg alias.cn cherry-pick\ -n
  _gcfg alias.co checkout
  _gcfg alias.cr cherry-pick
  _gcfg alias.d diff
  _gcfg alias.dc diff\ --cached
  _gcfg alias.deps commit\ -m\ \'build\(deps\):\ update\ dependencies\'
  _gcfg alias.fixup commit\ --amend\ --no-edit
  _gcfg alias.fo fetch\ origin
  _gcfg alias.gr log\ --graph\ --decorate=short\ --abbrev-commit\ --pretty=short
  _gcfg alias.hardreset '!f() { read -p "Hard-reset this branch to upstream? (y/N): " confirm && [ "y" = "$confirm" ] && git reset --hard @{u}; }; f'
  _gcfg alias.ig status\ --ignored
  _gcfg alias.kl clean\ -ffdx\ -e\ .idea\ -e\ .envrc\ -e\ .tool-versions
  _gcfg alias.mine \!git\ log\ --author=\"\$\(git\ config\ --get\ user.name\)\"\ --pretty=\'%C\(yellow\)%h%Creset\ %an\ %C\(cyan\)%ad%Creset\ %Cred%cd%Creset\ %Cgreen%s%Creset\'
  _gcfg alias.mu merge\ @\{u\}
  _gcfg alias.pend log\ @\{u\}..HEAD
  _gcfg alias.rc rebase\ --continue
  _gcfg alias.recent "!r() { refbranch=\$1 count=\$2; git for-each-ref --sort=-committerdate 'refs/remotes/origin/*' --format='%(refname:short)|%(HEAD)%(color:yellow)%(refname:lstrip=3)|%(color:bold green)%(committerdate:relative)|%(color:blue)%(subject)|%(color:magenta)%(authorname)%(color:reset)' --color=always --count=\${count:-20} | while read line; do branch=\$(echo \"\$line\" | awk 'BEGIN { FS = \"|\" }; { print \$1 }' | tr -d '*'); ahead=\$(git rev-list --count \"\${refbranch:-origin/main}..\${branch}\"); behind=\$(git rev-list --count \"\${branch}..\${refbranch:-origin/main}\"); colorline=\$(echo \"\$line\" | sed 's/^[^|]*|//'); echo \"\$ahead|\$behind|\$colorline\" | awk -F'|' -vOFS='|' '{\$5=substr(\$5,1,70)}1' ; done | ( echo \"ahead|behind|branch|lastcommit|message|author\" && cat) | column -ts'|';}; r"
  _gcfg alias.ri rebase\ --interactive
  _gcfg alias.sk stash\ -k
  _gcfg alias.st status
  _gcfg alias.upst log\ origin/main..HEAD
  _gcfg alias.vf diff\ --cached\ --check
  _gcfg alias.wip '!f() { git commit --no-verify -m "chore(wip): in-progress${1:+: $*}"; }; f'
  _gcfg color.diff-highlight.newhighlight green\ bold\ 22
  _gcfg color.diff-highlight.newnormal green\ bold
  _gcfg color.diff-highlight.oldhighlight red\ bold\ 52
  _gcfg color.diff-highlight.oldnormal red\ bold
  _gcfg color.diff.commit yellow\ bold
  _gcfg color.diff.frag magenta\ bold
  _gcfg color.diff.meta yellow
  _gcfg color.diff.new green\ bold
  _gcfg color.diff.old red\ bold
  _gcfg color.diff.whitespace red\ reverse
  _gcfg color.ui true
  _gcfg init.defaultbranch main
  _gcfg push.default simple
}

function _gcfg() {
  git config -f ~/.gitconfig "$@"
}

function _gcfg_rm_section() {
  git config -f ~/.gitconfig --remove-section "$@"
}

function _apply_if_delta() {
  if hash delta &> /dev/null; then
    _gcfg_rm_section color.diff
    _gcfg_rm_section color.diff-highlight

    _gcfg core.pager delta
    _gcfg delta.light false
    _gcfg delta.line-numbers true
    _gcfg delta.navigate true
    _gcfg diff.colormoved default
    _gcfg interactive.difffilter delta\ --color-only
    _gcfg merge.conflictstyle diff3
  fi
}

function _expandtab() {
  local content=''

  # cross-platform replacement that works for macOS and Linux
  content="$(sed -e 's/\t/  /g' ~/.gitconfig)"
  echo "$content" > ~/.gitconfig
}

_build_gitconfig
_apply_if_delta
_expandtab
