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
  _gcfg alias.fixup commit\ --amend\ --no-edit
  _gcfg alias.fo fetch\ origin
  _gcfg alias.gr log\ --graph\ --decorate=short\ --abbrev-commit\ --pretty=short
  _gcfg alias.ig status\ --ignored
  _gcfg alias.kl clean\ -ffdx\ -e\ .idea\ -e\ .envrc\ -e\ .tool-versions
  _gcfg alias.mine \!git\ log\ --author=\"\$\(id\ -F\)\"\ --pretty=\'%C\(yellow\)%h%Creset\ %an\ %C\(cyan\)%ad%Creset\ %Cred%cd%Creset\ %Cgreen%s%Creset\'
  _gcfg alias.mu merge\ @\{u\}
  _gcfg alias.pend log\ @\{u\}..HEAD
  _gcfg alias.rc rebase\ --continue
  _gcfg alias.ri rebase\ --interactive
  _gcfg alias.st status
  _gcfg alias.upst log\ origin/main..HEAD
  _gcfg alias.vf diff\ --cached\ --check
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

    _gcfg add.interactive.usebuiltin false
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
  sed -i'' -e 's/\t/  /g' ~/.gitconfig
}

_build_gitconfig
_apply_if_delta
_expandtab
