set nocompatible
:set autoread


filetype off
" 
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'flazz/vim-colorschemes'
" Plugin 'davidhalter/jedi-vim'
" Bundle 'djoshea/vim-autoread'
" Plugin 'klen/python-mode'
" Plugin 'jistr/vim-nerdtree-tabs'
" 
" Plugin 'lervag/vimtex'
"  
" Plugin 'rdnetto/YCM-Generator'
Plugin 'scrooloose/nerdtree'
" Plugin 'benmills/vimux'
Plugin 'altercation/vim-colors-solarized'
Plugin 'Valloric/YouCompleteMe'
" Plugin 'scrooloose/syntastic'
" Plugin 'aperezdc/vim-template'
" Plugin 'MarcWeber/vim-addon-mw-utils'
" Plugin 'tomtom/tlib_vim'
" Plugin 'garbas/vim-snipmate'
" Plugin 'honza/vim-snippets'
" Plugin 'editorconfig/editorconfig-vim'
" Plugin 'scrooloose/nerdcommenter'

" 
" 
call vundle#end()          


let g:ycm_global_ycm_extra_conf = ''
filetype plugin indent on   

set nrformats=alpha,bin,octal,hex
set number
syntax on
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
set hls
set ic
