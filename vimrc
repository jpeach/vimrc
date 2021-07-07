" Copyright 2010-2021 James Peach
"
" Licensed under the Apache License, Version 2.0 (the "License");
" you may not use this file except in compliance with the License.
" You may obtain a copy of the License at
"
"     http://www.apache.org/licenses/LICENSE-2.0
"
" Unless required by applicable law or agreed to in writing, software
" distributed under the License is distributed on an "AS IS" BASIS,
" WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
" See the License for the specific language governing permissions and
" limitations under the License.

" Set up plugins.
call plug#begin('~/.vim/bundle')

" https://github.com/fatih/vim-go
Plug 'fatih/vim-go', { 'tag': '*', 'do': ':GoUpdateBinaries' }

" https://github.com/junegunn/fzf.vim
Plug 'junegunn/fzf.vim'

" https://github.com/majutsushi/tagbar
Plug 'majutsushi/tagbar'

" https://github.com/tpope/vim-fugitive
Plug 'tpope/vim-fugitive'

" https://github.com/tpope/vim-sensible
Plug 'tpope/vim-sensible'

" https://github.com/morhetz/gruvbox
Plug 'morhetz/gruvbox'

" https://github.com/vim-airline/vim-airline
Plug 'vim-airline/vim-airline'

" https://github.com/vim-airline/vim-airline-themes
Plug 'vim-airline/vim-airline-themes'

" https://github.com/ctrlpvim/ctrlp.vim
Plug 'ctrlpvim/ctrlp.vim'

" https://github.com/altercation/vim-colors-solarized
Plug 'altercation/vim-colors-solarized'

" https://github.com/mileszs/ack.vim
Plug 'mileszs/ack.vim'

" https://github.com/nvie/vim-flake8
Plug 'nvie/vim-flake8'

" https://github.com/rust-lang/rust.vim
Plug 'rust-lang/rust.vim'

" https://github.com/neovim/nvim-lspconfig
if has('nvim')
    Plug 'neovim/nvim-lspconfig'
endif

call plug#end()

" Force the sensible plugin to run now so that we can override what it
" does if we want.
call plug#load('vim-sensible')

" Set , as <Leader>
let mapleader=","

" Be paranoid, and automatically set up autobackup
if (!isdirectory(expand("~/tmp/vim.backup")))
    call mkdir(expand("~/tmp/vim.backup"), "p", 0755)
endif

set backupdir=~/tmp/vim.backup
set backup
set writebackup
set backupext=.bak

" Basic settings.
set nocompatible  " Don't be vi compatible
set softtabstop=4
set shiftwidth=4
set textwidth=79
set expandtab
set smarttab
set autoindent
set showmatch
set visualbell
set laststatus=2  " Last window always gets a status line
set statusline=\ [%n]\ %f\ %m%r%=%l/%L
set modeline    " Turn modeline support on
set modelines=2
set matchpairs+=<:> " Add bracket matching for angled brackets

" Make sure ruler is off so that Ctrl-G shows the column.
set noruler

" Highlight the line the cursor is on, but only in GUI mode otherwise it is
" underlined in an really ugly way.
if (has("gui_running"))
    set cursorline
endif

" Obviously we want syntax highlighting :)
syntax on

" Check for the Homebrew install of fzf.
if isdirectory('/usr/local/opt/fzf/plugin')
    set runtimepath+=/usr/local/opt/fzf
    " Map ,t to fuzzy find
    noremap <Leader>t :FZF<CR>
" Check for the Fedora install of fzf.
elseif  isdirectory('/usr/share/vim/vimfiles/plugin')
    set runtimepath+=/usr/share/vim/vimfiles
    " Map ,t to fuzzy find
    noremap <Leader>t :FZF<CR>
else
    " CtrlP - fuzzy file finder; http://kien.github.io/ctrlp.vim/
    " Map ,t to Most Recently Used file find
    noremap <Leader>t :CtrlP<CR>
    " Map ,b to buffer find
    noremap <Leader>b :CtrlPBuffer<CR>
endif

" Key bindings
noremap <C-A> :b#<CR>
noremap <C-N> :bn<CR>
noremap <C-P> :bp<CR>

" Make regex special characters special by default (see :help pattern).
noremap / /\v
vnoremap / /\v

filetype plugin indent on

" Load a decent man page viewer
runtime ftplugin/man.vim
noremap K :Man <C-R>=expand("<cword>")<CR><CR>

" special handling for different file types
autocmd BufNewFile,BufRead *.log set tw=65
autocmd BufNewFile,BufRead *.txt set tw=65
autocmd BufNewFile,BufRead *.msg set tw=65

" Turn off funky tabbing modes for makefiles
autocmd FileType make set sts=0 ts=8 sw=8 noet

" Set 2-space indentation for YAML.
autocmd FileType yaml set ts=2 sts=2 sw=2 et

" Map ,8 to the flake8 command in python mode
autocmd FileType python noremap <buffer> <Leader>8 :call Flake8()<CR>

" Turn on C indentation.
set cindent
" Indentation options:
" :0  (cino-:) Turn off indentation of case labels in switches.
set cinoptions=:0

"
" Enable search-related options: highlight matches in a search
" (hls), show the current matching pattern as you search (is),
" ignore case (ic) unless you are searching for both upper and
" lowercase letters (scs).
set hlsearch is ic scs
noremap <CR> :nohlsearch<CR>

" Map <Leader>a to do an Ack search of the current word
noremap <Leader>a :Ack <C-R>=expand("<cword>")<CR><CR>
" Map ,s to git-stripspace the current buffer
noremap <Leader>s :%!git stripspace<CR>
" Map ,j to use jq to format the current buffer
noremap <Leader>j :%!jq .<CR>

" Map ,T to toggle the tagbar plugin.
noremap <Leader>T :TagbarToggle<CR>

" Return the current cursor position as "file:line:col"
function! s:position()
    return expand('%') . ':' . line('.') . ':' . col('.')
endfunction

" Initialize cscope-lsp, see https://github.com/jpeach/cscope-lsp
function! s:cscope_lsp_init(lsp)
    " Name of the DB file for cscope add. vim requires that this be a
    " regular file that exists.
    let l:db = 'compile_commands.json'

    execute ':set cscopeprg=' . exepath('cscope-lsp')
    execute ':cs add ' . l:db . ' . ' . ' --cquery=' . exepath(a:lsp)

    " css: Find symbol
    noremap <Leader>cs :cs find s <C-R>=<SID>position()<CR><CR>
    " csg: Find definition
    noremap <Leader>cg :cs find g <C-R>=<SID>position()<CR><CR>
    " csc: Find callers
    noremap <Leader>cc :cs find c <C-R>=<SID>position()<CR><CR>
    " csd: Find callees
    noremap <Leader>cd :cs find d <C-R>=<SID>position()<CR><CR>
    " cst: Find text string
    noremap <Leader>ct :cs find t <C-R>=<SID>position()<CR><CR>
    " cse: Find egrep pattern
    noremap <Leader>ce :cs find e <C-R>=<SID>position()<CR><CR>
    " csf: Find file
    noremap <Leader>cf :cs find f <C-R>=<SID>position()<CR><CR>
    " csi: Find files #including this
    nnoremap <Leader>ci :cs find i <C-R>=<SID>position()<CR><CR>
endfunction

" Initialize gtags-cscope.
function! s:cscope_gtags_init()
    execute ':set cscopeprg=' . exepath('gtags-cscope')
    execute ":cs add GTAGS"

    " css: Find symbol
    nnoremap <Leader>cs :cs find s <C-R>=expand("<cword>")<CR><CR>
    " csg: Find definition
    nnoremap <Leader>cg :cs find g <C-R>=expand("<cword>")<CR><CR>
    " csc: Find callers
    nnoremap <Leader>cc :cs find c <C-R>=expand("<cword>")<CR><CR>
    " csd: Find callees
    nnoremap <Leader>cd :cs find d <C-R>=expand("<cword>")<CR><CR>
    " cst: Find text string
    nnoremap <Leader>ct :cs find t <C-R>=expand("<cword>")<CR><CR>
    " cse: Find egrep pattern
    nnoremap <Leader>ce :cs find e <C-R>=expand("<cword>")<CR><CR>
    " csf: Find file
    nnoremap <Leader>cf :cs find f <C-R>=expand("<cfile>")<CR><CR>
    " csi: Find files #including this
    nnoremap <Leader>ci :cs find i <C-R>=expand("<cfile>")<CR><CR>
endfunction

" Initialize cscope keybindings for Go using vim-go.
function! s:cscope_go_init()
    " css: Find symbol
    nnoremap <Leader>cs :GoReferrers<CR><CR>
    " csg: Find definition
    nnoremap <Leader>cg :GoDef<CR><CR>
    " csc: Find callers
    nnoremap <Leader>cc :GoCallers<CR><CR>
    " csd: Find callees
    nnoremap <Leader>cd :GoCallees<CR><CR>
    " ,ci: Find implementation
    nnoremap <Leader>ci :GoImplements<CR><CR>
    " cst: Find text string
    " cse: Find egrep pattern
    " csf: Find file
endfunction

" Initialize neovim LSP, see https://github.com/neovim/nvim-lspconfig.
function! s:nvim_lsp_init()
    if !has('nvim')
        return
    endif

    lua <<EOF
local lspconfig = require('lspconfig')
lspconfig.clangd.setup {}
EOF

    " ,cc: Find callers
    nnoremap <Leader>cc :lua vim.lsp.buf.incoming_calls()<CR>
    " ,cd: Find callees
    nnoremap <Leader>cd :lua vim.lsp.buf.outgoing_calls()<CR>
    " ,cs: Find symbol (references)
    nnoremap <Leader>cs :lua vim.lsp.buf.references()<CR>
    " ,cg: Find definition
    nnoremap <Leader>cg :lua vim.lsp.buf.definition()<CR>
    " ,ci: Find implementation
    nnoremap <Leader>ci :lua vim.lsp.buf.implementation()<CR>
    " ,ch: Switch to source header
    nnoremap <Leader>ch :ClangdSwitchSourceHeader<CR>
endfunction

" Set up gtags (cscope) integration
function! CscopeInit()
    if !has("cscope")
      return
    endif

    set csto=0    " Search cscope before tags.
    set nocsverb  " Don't be verbose

    let l:cquery = filereadable('.cquery') || filereadable('compile_commands.json')
    let l:gtags = filereadable('GTAGS')

    if executable('cscope-lsp') && executable('cquery') && l:cquery
        call s:cscope_lsp_init("cquery")
    elseif executable('cscope-lsp') && executable('ccls') && l:cquery
        call s:cscope_lsp_init("ccls")
    elseif executable('gtags-cscope') && l:gtags
        call s:cscope_gtags_init()
    endif

endfunction

call CscopeInit()
autocmd FileType go call s:cscope_go_init()

" We can call this unconditionally because it's a noop outside of neovim.
call s:nvim_lsp_init()

" Highlight trailing whitespace.
if has("syntax") && (&t_Co > 2 || has("gui_running"))
    syntax on
    function! ActivateInvisibleCharIndicator()
        syntax match TrailingSpace "[ \t]\+$" display containedin=ALL
        highlight TrailingSpace ctermbg=Red
    endf
    autocmd BufNewFile,BufRead * call ActivateInvisibleCharIndicator()
endif

" Autostrip trailing whitespace on save.
" too dangerous - screws me when making quilt patches
" autocmd BufWritePre * :%s/\s\+$//e

if has("gui_running")
    set guifont=NotoMono:h12
    set lines=60
    set guioptions-=T " Hide the GUI toolbar
endif

set termguicolors

" All my terminals are dark these days. I wonder how I could autodetect this?
set background=dark

" The default neovim colorscheme is nicer than gruvbox.
if !has('nvim')
    colorscheme gruvbox
endif

set number
set relativenumber

" Load .vimrc and .exrc files in the current working directory
set exrc
" But do it carefully
set secure

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Set plugin configurations.
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if filereadable($HOME . '/bin/ctags')
    let g:tagbar_ctags_bin = $HOME . '/bin/ctags'
endif

" 60 is a more readable width than 40, especially if the
" terminal is fullscreen.
if winwidth(0) > 80
    let g:tagbar_width = 60
endif

" Don't let the CtrlP plugin map <C-P>
let g:ctrlp_map=''

let g:alternateExtensions_hpp = "cpp,cc,c"
let g:alternateExtensions_cc = "hpp,h"

" Use goimports to format imports idiomatically.
let g:go_fmt_command = 'goimports'

let g:go_fmt_options = {
   \ 'gofmt': '-s',
   \ }

" Enable more syntax highlights.
let g:go_highlight_types = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1

" Use golang-ci for metalinter.
let g:go_metalinter_command = 'golangci-lint'

let g:go_metalinter_autosave_enabled = ['vet', 'revive', 'errcheck']

" Run vet, lint, etc on save. This picks up a reasonable amount of issues.
let g:go_metalinter_autosave = 1

" Automatically highlight matching identifiers
let g:go_auto_sameids = 1

" Always use quickfix llists rather than location lists so that :.cc (jump to
" error under cursor) works
let g:go_list_type = "quickfix""

let g:go_def_mode = 'gopls'
let g:go_info_mode = 'gopls'

" Show the type info (|:GoInfo|) for the word under the cursor automatically.
let g:go_auto_type_info = 1

" Autoformat rust code on save.
let g:rustfmt_autosave = 1
