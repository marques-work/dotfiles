call plug#begin('~/.vim/plugged')
  Plug 'pgavlin/pulumi.vim'
  Plug 'catppuccin/vim', { 'as': 'catppuccin' }
  Plug 'wadackel/vim-dogrun'
  Plug 'flrnd/candid.vim'
  Plug 'megantiu/true.vim'
  Plug 'dfrunza/vim'
  Plug 'Mcmartelle/vim-monokai-bold'
  Plug 'relastle/bluewery.vim'
  Plug 'Resonious/vim-camo'
  Plug 'arzg/vim-corvine'
  Plug 'plainfingers/black_is_the_color'
  Plug 'sainnhe/archived-colors'
  Plug 'Rigellute/shades-of-purple.vim'
  Plug 'kjssad/quantum.vim'
  Plug 'KurtPreston/vimcolors'
  Plug 'dunstontc/vim-vscode-theme'
  Plug 'leafgarland/typescript-vim'
  Plug 'benknoble/vim-mips'

  if executable('fzf')
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
  endif
call plug#end()

syntax on
set number
set noswapfile
set hlsearch
set incsearch
set showcmd
set modeline
let mapleader = " "

" This messes up default color schemes; look much better with this turned off
"set termguicolors

set background=dark

if has("gui_running")
  if has("gui_gtk3") || has("gui_gtk2")
    set guifont=Hack\ 18
  elseif has("gui_macvim")
    set guifont=Hack:h18
  endif

  colo catppuccin_mocha
  "colo pulumi
else
  set t_Co=256
  "colo desert
  "colo lizard
  "colo luna-term
  colo elflord
  "colo neuromancer
endif

" `tabstop`
" The width of a hard tabstop measured in "spaces" -- effectively the (maximum)
" width of an actual tab character.
"
" `shiftwidth`
" The size of an "indent". It's also measured in spaces, so if your code base
" indents with tab characters then you want shiftwidth to equal the number of
" tab characters times tabstop. This is also used by things like the =, > and
" < commands.
"
" `softtabstop`
" Setting this to a non-zero value other than tabstop will make the tab key
" (in insert mode) insert a combination of spaces (and possibly tabs) to
" simulate tab stops at this width.
"
" `expandtab`
" Enabling this will make the tab key (in insert mode) insert spaces instead
" of tab characters. This also affects the behavior of the retab command.
"
" `smarttab`
" Enabling this will make the tab key (in insert mode) insert spaces or tabs
" to go to the next indent of the next tabstop when the cursor is at the
" beginning of a line (i.e. the only preceding characters are whitespace).
set tabstop=8 softtabstop=2 expandtab shiftwidth=2 smarttab
