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
