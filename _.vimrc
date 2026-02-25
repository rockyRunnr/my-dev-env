set shell=/bin/bash

set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()

Plugin 'gmarik/Vundle.vim'

Plugin 'tpope/vim-sensible' " auto config setting
Plugin 'majutsushi/tagbar'
Plugin 'scrooloose/nerdtree'
" Plugin 'scrooloose/nerdcommenter'

Plugin 'snipMate'
Plugin 'nanotech/jellybeans.vim'
Plugin 'vim-airline/vim-airline' " vim status bar
Plugin 'vim-airline/vim-airline-themes'

Plugin 'airblade/vim-gitgutter' " vim with git status(added, modified, and removed lines)
Plugin 'tpope/vim-fugitive' " vim with git command(e.g., Gdiff)

Plugin 'nathanaelkane/vim-indent-guides'

" ctags easy tool
Plugin 'xolox/vim-misc'
" Plugin 'xolox/vim-easytags'

Plugin 'chrisbra/csv.vim'
Plugin 'plasticboy/vim-markdown'
Plugin 'blueyed/vim-diminactive'
Plugin 'elzr/vim-json'

Plugin 'vim-scripts/DiffGoFile' "ctags with diff file

Plugin 'prabirshrestha/async.vim'
Plugin 'prabirshrestha/vim-lsp'
Plugin 'mattn/vim-lsp-settings'
" Plugin 'prabirshrestha/asyncomplete.vim'
Plugin 'prabirshrestha/asyncomplete-lsp.vim'

Plugin 'SirVer/ultisnips'

" Plugin 'ryanolsonx/vim-lsp-python'
Plugin 'prabirshrestha/asyncomplete.vim'
Plugin 'thomasfaingnaert/vim-lsp-snippets'
Plugin 'thomasfaingnaert/vim-lsp-ultisnips'

call vundle#end()

" for ultisnips
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" for lsp
if executable('clangd')
    au User lsp_setup call lsp#register_server({
                \ 'name': 'clangd',
                \ 'cmd': {server_info->['clangd', '-background-index']},
                \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
                \ })
endif

let g:lsp_log_verbose = 1
let g:lsp_log_file = expand('~/vim-lsp.log')
let g:lsp_settings_servers_dir = '/home/i520485/'

if executable('pyls')
    " pip install python-language-server
    au User lsp_setup call lsp#register_server({
                \ 'name': 'pyls',
                \ 'cmd': {server_info->['pyls']},
                \ 'whitelist': ['python'],
                \ })
endif

augroup lsp_install
        au!
        " call s:on_lsp_buffer_enabled only for languages that has the server registered.
        autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

let mapleader = ","
nnoremap <Leader>d :LspDefinition<CR>
nnoremap <Leader>r :LspReferences<CR>

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> <f2> <plug>(lsp-rename)
    " refer to doc to add more commands
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only
    " for languages that has the server
    " registered.
    autocmd User lsp_buffer_enabled
    call s:on_lsp_buffer_enabled()
augroup END

let g:lsp_diagnostics_echo_cursor = 1


" for ale
" let g:ale_fix_on_save = 1

" for blueyed/vim-diminactive
let g:diminactive_enable_focus = 1

" for taglist
nmap <F8> :Tagbar<CR>

" for easytags
" let g:easytags_file = '~/.vim/tags'
" let g:easytags_by_filetype = 1

" set tag=./tags;/ " easy-tag
" let g:easytags_dynamic_files = 1

" let g:easytags_events = ['BufWritePost'] " generate tags only files are stored

" let g:easytags_async=1
" let g:easytags_auto_highlight = 0

" keep track structure members
" let g:easytags_include_members = 1

" for indent guide
let g:indentguides_spacechar = '┆'
let g:indentguides_tabchar = '|'
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level=2
let g:indent_guides_guide_size=1


" for vim-airline
let g:airline#extensions#tabline#enabled = 1 " turn on buffer list
let g:airline_theme='hybrid'
set laststatus=2 " turn on bottom bar
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
nnoremap <leader>q :bp<CR>
nnoremap <leader>w :bn<CR>

" 4 'space's instead of 'tab'
set smartindent
set tabstop=4
set expandtab
" << or >>
set shiftwidth=4

set nowrapscan " do not get back while search
set nobackup
set noswapfile
set nu
set autoindent

" for hangul korean
set tenc=utf-8
set encoding=utf-8
set fencs=ucs-bom,utf-8,euc-kr.latin1

set hlsearch
set ignorecase " == set ic, != set noic
set incsearch
set cindent
set ruler " locate cursor
set nocompatible " no compatible with original vi

set sm " show other-side bracket
set title
set cursorline
set visualbell
set lbr " keep a word atomic

set nofoldenable " disable folding
set background=dark
set backspace=eol,start,indent " when backspace, go previous line
set history=1000 " vi edit history, stored viminfo
set mouse=a
set t_Co=256
set clipboard=unnamedplus,autoselect
" set paste

if has('cscope')
	set csprg=/usr/bin/cscope
	set csto=0
	set cst
	set nocsverb
    set cscopetag
	if filereadable("./cscope.out")
		cs add cscope.out
	endif
	set csverb
endif

syntax enable
filetype indent on
highlight Comment term=bold cterm=bold ctermfg=4

set background=dark
colorscheme jellybeans

" git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
" ~/.fzf/install
set rtp+=~/.fzf

nnoremap <leader>s :cs f s <C-R><C-W><CR>
nnoremap <leader>g :cs f g <C-R><C-W><CR>
nnoremap <leader>t :cs f t <C-R><C-W><CR>

map q <Nop>


highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

