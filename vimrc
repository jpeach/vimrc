" Copyright 2010 James Peach
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

" Useful settings
set nocompatible
set sts=4
set sw=4
set tw=79
set smarttab
syntax on
set backupdir=~/tmp/vim.backup
set autoindent
set backup
set writebackup
set showmatch
set cindent
set visualbell
set laststatus=2
set statusline=\ [%n]\ %f\ %m%r%=%l/%L\
" Turn modeline support on
set modeline
set modelines=2
" Add bracket matching for angled brackets.
set matchpairs+=<:>
"
" Key bindings
map g 1G
map <C-A> :b#<CR>
map <C-N> :bn<CR>
map <C-P> :bp<CR>
"
" special handling for different file types
:filetype on
autocmd BufNewFile,BufRead *.log set tw=65
autocmd BufNewFile,BufRead *.txt set tw=65
autocmd BufNewFile,BufRead *.msg set tw=65
" turn off funky tabbing modes for makefiles
autocmd BufNewFile,BufRead *[Mm]akefile* set sts=0 noet ts=8 sw=8
autocmd BufNewFile,BufRead *.make set sts=0 noet ts=8 sw=8
"
" Highlight searches
set hlsearch
map <CR> :nohlsearch<CR>
"
" Set up cscope inntegration
if has("cscope")
    set csto=0
    set nocsverb
    if filereadable("GTAGS")
	set cscopeprg=/opt/local/bin/gtags-cscope
	let cscopedb="GTAGS"
	:execute ":cs add GTAGS"
    endif

    " css: Find symbol
    map css :cs find s <C-R>=expand("<cword>")<CR><CR>
    " csg: Find definition
    map csg :cs find g <C-R>=expand("<cword>")<CR><CR>
    " csc: Find callers
    map csc :cs find c <C-R>=expand("<cword>")<CR><CR>
    " csd: Find callees
    map csd :cs find d <C-R>=expand("<cword>")<CR><CR>
    " cst: Find text string
    map cst :cs find t <C-R>=expand("<cword>")<CR><CR>
    " cse: Find egrep pattern
    map cse :cs find e <C-R>=expand("<cword>")<CR><CR>
    " csf: Find file
    map csf :cs find f <C-R>=expand("<cfile>")<CR><CR>
    " csi: Find files #including this
    map csi :cs find i <C-R>=expand("<cfile>")<CR><CR>

endif
"
" shift-q: Quilt shortcut
map <S-Q> :!$HOME/bin/q<Space>
"
" Load a decent man page viewer
runtime ftplugin/man.vim
map K :Man <C-R>=expand("<cword>")<CR><CR>
"
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
"
"
" desert is illegible in SnowLeopard Terminal :(
if has("gui_running")
"   set guifont=Consolas:h12.0
    set guifont="Menlo Regular:h12.00"
    colorscheme desert
else
    colorscheme default
endif
