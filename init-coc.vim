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

" Initialize coc.nvim keybindings and config, see https://github.com/neoclide/coc.nvim
function! s:nvim_coc_init()
    " Map CoC symbol navigation
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)

    " ,cs: Find symbol references
    noremap <Leader>cs <Plug>(coc-references-used)

    " ,cg: Find definition
    noremap <Leader>cg <Plug>(coc-definition)

    " ,ci: Find implementation
    noremap <Leader>ci <Plug>(coc-implementation)

    " ,cy: Find type
    noremap <Leader>ct <Plug>(coc-type-definition)

    " Make <CR> to accept selected completion item or notify coc.nvim to format
    " <C-g>u breaks current undo, please make your own choice
    inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

endfunction

if has('nvim')
    call s:nvim_coc_init()
endif
