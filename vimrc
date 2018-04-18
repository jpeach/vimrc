" Copyright 2010-2016 James Peach
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

execute pathogen#infect()
execute pathogen#helptags()

" Force the sensible plugin to run now so that we can override what it
" does if we want.
runtime! plugin/sensible.vim

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

" Set , as <Leader>
let mapleader=","

" Don't let the CtrlP plugin map <C-P>
let g:ctrlp_map=''

let g:alternateExtensions_hpp = "cpp,cc,c"
let g:alternateExtensions_cc = "hpp,h"

" Be paranoid, and automatically set up autobackup
if (!isdirectory(expand("~/tmp/vim.backup")))
    call mkdir(expand("~/tmp/vim.backup"), "p", 0755)
endif
set backupdir=~/tmp/vim.backup
set backup
set writebackup
set backupext=.bak

" Key bindings
map <C-A> :b#<CR>
map <C-N> :bn<CR>
map <C-P> :bp<CR>
"
" Make regex special characters special by default (see :help pattern).
noremap / /\v
vnoremap / /\v

filetype plugin indent on


" special handling for different file types
autocmd BufNewFile,BufRead *.log set tw=65
autocmd BufNewFile,BufRead *.txt set tw=65
autocmd BufNewFile,BufRead *.msg set tw=65
" Turn off funky tabbing modes for makefiles
autocmd BufNewFile,BufRead *[Mm]akefile* set sts=0 noet ts=8 sw=8
autocmd BufNewFile,BufRead *.make set sts=0 noet ts=8 sw=8
" Map ,8 to the flake8 command in python mode
autocmd FileType python map <buffer> <Leader>8 :call Flake8()<CR>

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
map <CR> :nohlsearch<CR>

" Map <Leader>a to do an Ack search of the current word
map <Leader>a :Ack <C-R>=expand("<cword>")<CR><CR>
" Map ,s to git-stripspace the current buffer
map <Leader>s :%!git stripspace<CR>
" Map ,j to use jq to format the current buffer
map <Leader>j :%!jq .<CR>

" CtrlP - fuzzy file finder; http://kien.github.io/ctrlp.vim/
" Map ,t to Most Recently Used file find
map <Leader>t :CtrlP<CR>
" Map ,b to buffer find
map <Leader>b :CtrlPBuffer<CR>

" Map ,T to toggle the tagbar plugin.
map <Leader>T :TagbarToggle<CR>

if filereadable($HOME . '/bin/ctags')
    let g:tagbar_ctags_bin = $HOME . '/bin/ctags'
endif

" 60 is a more readable width than 40, especially if the
" terminal is fullscreen.
if winwidth(0) > 80
    let g:tagbar_width = 60
endif

" Set up gtags (cscope) integration
function! CscopeInit()
    if !has("cscope")
      return
    endif

    set csto=0      " Search cscope before tags.
    set nocsverb    " Don't be verbose

    let found = 0

    for d in [ '/opt/local/bin', '/usr/local/bin', '/usr/bin' ]
        let gs = d . "/gtags-cscope"
        if filereadable(gs) && filereadable("GTAGS")
            execute ":set cscopeprg=" . gs
            execute ":cs add GTAGS"
            break
        endif
    endfor

    " css: Find symbol
    map <Leader>cs :cs find s <C-R>=expand("<cword>")<CR><CR>
    " csg: Find definition
    map <Leader>cg :cs find g <C-R>=expand("<cword>")<CR><CR>
    " csc: Find callers
    map <Leader>cc :cs find c <C-R>=expand("<cword>")<CR><CR>
    " csd: Find callees
    map <Leader>cd :cs find d <C-R>=expand("<cword>")<CR><CR>
    " cst: Find text string
    map <Leader>ct :cs find t <C-R>=expand("<cword>")<CR><CR>
    " cse: Find egrep pattern
    map <Leader>ce :cs find e <C-R>=expand("<cword>")<CR><CR>
    " csf: Find file
    map <Leader>cf :cs find f <C-R>=expand("<cfile>")<CR><CR>
    " csi: Find files #including this
    map <Leader>ci :cs find i <C-R>=expand("<cfile>")<CR><CR>

endfunction

call CscopeInit()

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
    set guifont=Menlo\ Regular:h10
    " Make the printfont small so we can get a more on the page (obviously)
    set printfont=Menlo\ Regular:h6
    set lines=60
    set guioptions-=T " Hide the GUI toolbar

    colorscheme solarized
endif

set termguicolors

" All my terminals are dark these days. I wonder how I could autodetect this?
set background=dark

set relativenumber

" Set up the fugitive plugin
runtime plugin/fugitive.vim
if exists("*fugitive#statusline")
    set statusline=\ [%n]\ %{fugitive#statusline()}\ %f\ %m%r%=%l/%L\
endif

" Load a decent man page viewer
runtime ftplugin/man.vim
map K :Man <C-R>=expand("<cword>")<CR><CR>

augroup Tmux "{{{2
    au!

    autocmd VimEnter,BufNewFile,BufReadPost * call system('tmux rename-window "vim - ' . split(substitute(getcwd(), $HOME, '~', ''), '/')[-1] . '"')
    autocmd VimLeave * call system('tmux rename-window ' . split(substitute(getcwd(), $HOME, '~', ''), '/')[-1])
augroup END

" Load .vimrc and .exrc files in the current working directory
set exrc
" But do it carefully
set secure

" Use goimports to format imports idiomatically.
let g:go_fmt_command = "goimports"

" Enable more syntac highlights.
let g:go_highlight_types = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1

" Run vet, lint, etc on save. This picks up a reasonable amount of issues.
let g:go_metalinter_autosave = 1

" Autoformat rust code on save.
let g:rustfmt_autosave = 1
