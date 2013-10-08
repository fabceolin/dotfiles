set nocompatible
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

" Synastic
let g:syntastic_check_on_open = 1
let g:syntastic_enable_signs = 1
let g:syntastic_cpp_include_dirs = [ '/opt/ibm/ILOG/CPLEX_Studio125/cplex/include/', '/opt/ibm/ILOG/CPLEX_Studio125/concert/include/' , '/opt/ibm/ILOG/CPLEX_Studio125/opl/include/' ]
let g:syntastic_cpp_compiler_options = "-std=cxx11"

set completeopt = "menu,menuone,longest"
let g:SuperTabDefaultCompletionType = "context"
let g:clang_complete_copen = 1
let g:clang_debug = 1

map :cpy :0r Header.txt
map :trail :%s/\s\+$//e

" let &t_ti.="\e[?7727h"
"let &t_te.="\e[?7727l"
"noremap <Esc>O[ <Esc>
"noremap! <Esc>O[ <C-c>

"#autocmd BufWritePre * :%s/\s\+$//e

if exists('+colorcolumn')
    set colorcolumn=80
else
    au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif

let g:DoxygenToolkit_commentType = "C++"

function! GnuIndent()
    setlocal cinoptions=>4,n-2,{2,^-2,:2,=2,g0,h2,p5,t0,+2,(0,u0,w1,m1
    setlocal shiftwidth=2
    setlocal tabstop=4
endfunction
au FileType c,cpp call GnuIndent() 

function! IndentLine()
"    .!astyle -p -P -H -U -o -O 
    .!indent -nbad -bap -nbc -bbo -hnl -br -brs -c33 -cd33 -ncdb -ce -ci4 -cli0 -d0 -di1 -nfc1 -i8 -ip0 -l9999 -lp -npcs -nprs -npsl -sai -saf -saw -ncs -nsc -sob -nfca -cp33 -ss -ts8 -il1
    .normal == 
endfunction

function! IndentBlock()
    '<,'>!indent -nbad -bap -nbc -bbo -hnl -br -brs -c33 -cd33 -ncdb -ce -ci4 -cli0 -d0 -di1 -nfc1 -i8 -ip0 -l9999 -lp -npcs -nprs -npsl -sai -saf -saw -ncs -nsc -sob -nfca -cp33 -ss -ts8 -il1
    '<,'>normal == 
endfunction


