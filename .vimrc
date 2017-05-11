set nocompatible

" https://github.com/junegunn/vim-plug
call plug#begin("~/.vim/plugins/")
" git wrapper
Plug 'tpope/vim-fugitive'

Plug 'flazz/vim-colorschemes'
Plug 'scrooloose/nerdtree' , { 'on':  'NERDTreeToggle' }
Plug 'junegunn/vim-easy-align'
Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }
Plug 'tpope/vim-commentary'
Plug 'junegunn/fzf' , { 'do' : './install.py' } 

" Plug 'davidhalter/jedi-vim'
" Bundle 'djoshea/vim-autoread'
" Plug 'klen/python-mode'
" Plug 'jistr/vim-nerdtree-tabs'
" Plug 'junegunn/vim-easy-align'
" Plug 'lervag/vimtex'
" Plug 'rdnetto/YCM-Generator'
" Plug 'benmills/vimux'
" Plug 'scrooloose/syntastic'
" Plug 'aperezdc/vim-template'
" Plug 'MarcWeber/vim-addon-mw-utils'
" Plug 'tomtom/tlib_vim'
" Plug 'garbas/vim-snipmate'
" Plug 'honza/vim-snippets'
" Plug 'editorconfig/editorconfig-vim'
" Plug 'scrooloose/nerdcommenter'
" itchyny/lightline.vim
call plug#end()

let g:ycm_global_ycm_extra_conf = ''

set encoding=utf-8
filetype plugin indent on   
syntax on
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab

set autoread  " Auto reload file on change
set number    " set nonumber
set nrformats=alpha,bin,octal,hex " Number Formats
set hls " Highlight Search  | set hlsearch | set nohlsearch
set ic " Ignore Case | set noic

map <C-\> :NERDTreeToggle<CR>



" Python
autocmd FileType python set sw=4
            \ set ts=4
            \ set sts=4

" Nerdtree
let NERDTreeWinSize=20 

