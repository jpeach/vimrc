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

" Initialize neovim LSP, see https://github.com/neovim/nvim-lspconfig.
function! s:nvim_lsp_init()
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

call s:nvim_lsp_init()
