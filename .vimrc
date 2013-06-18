" Tab key produces 4 spaces, and tab characters are converted to spaces
set tabstop=4
set shiftwidth=4
set expandtab
set background=dark
" when you start searching text with /, search is performed at every new character insertion
set incsearch
set nopaste
set autoindent
set fileformats=unix,dos
" docblock comments are continued when a newline is inserted
set comments=sr:/*,mb:*,ex:*/
syntax on
filetype on
filetype plugin on
" check syntax with Ctrl + L
autocmd FileType php noremap <C-L> :!/usr/bin/env php -l %<CR>
autocmd FileType phtml noremap <C-L> :!/usr/bin/env php -l %<CR>
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis

call pathogen#infect()

let g:syntastic_c_include_dirs = [ '/opt/ibm/ILOG/CPLEX_Studio125/cplex/include/', '/opt/ibm/ILOG/CPLEX_Studio125/concert/include/' ]

set completeopt = "menu,menuone,longest"
let g:SuperTabDefaultCompletionType = "context"
let g:clang_complete_copen = 1


