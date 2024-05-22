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
