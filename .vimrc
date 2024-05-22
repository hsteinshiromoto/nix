" ---
" Configuration: Plugin Manager
"
" References:
" 	[1] https://github.com/tpope/vim-pathogen
" ---
execute pathogen#infect()
syntax on
filetype plugin indent on

" ---
" Configuration: Gruvbox Theme
" ---
:set bg=dark
autocmd vimenter * ++nested colorscheme gruvbox

" ---
" Configuration: Code-minimap
"
" Requirements:
" 	[R1] Code-minimap: https://github.com/wfxr/code-minimap
"
" References:
" 	[1] https://github.com/wfxr/minimap.vim
" ---
let g:minimap_width = 10
let g:minimap_auto_start = 1
let g:minimap_auto_start_win_enter = 1

call plug#begin()

Plug 'junegunn/fzf'

call plug#end()
