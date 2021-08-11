" original: https://github.com/nickmccurdy/sane-defaults/blob/4e10f8a8774f6b3a678de96f74cd92f04cd83503/home/.vimrc

""""""
" UI "
""""""

" disable vi compatibility
set nocompatible

" automatically load changed files
set autoread

" auto-reload vimrc
autocmd! bufwritepost vimrc source ~/.vim/vimrc

" show the filename in the window titlebar
set title

" set encoding
set encoding=utf-8

" display incomplete commands at the bottom
set showcmd

" mouse support
set mouse=a

" line numbers
set number

" highlight cursor line
set cursorline

" wrapping stuff
"set textwidth=80
set colorcolumn=100

" ignore whitespace in diff mode
set diffopt+=iwhite

" Be able to arrow key and backspace across newlines
set whichwrap=bs<>[]

" Status bar
set laststatus=2

" remember last cursor position
autocmd BufReadPost *
	\ if line("'\"") > 0 && line("'\"") <= line("$") |
	\ 	exe "normal g`\"" |
	\ endif

" show '>   ' at the beginning of lines that are automatically wrapped
set showbreak=>\ \ \ 

" enable completion
set ofu=syntaxcomplete#Complete

" make laggy connections work faster
set ttyfast

" let vim open up to 100 tabs at once
set tabpagemax=100

" case-insensitive filename completion
set wildignorecase

"""""""""""""
" Searching "
"""""""""""""

set hlsearch "when there is a previous search pattern, highlight all its matches
set incsearch "while typing a search command, show immediately where the so far typed pattern matches
set ignorecase "ignore case in search patterns
set smartcase "override the 'ignorecase' option if the search pattern contains uppercase characters
set gdefault "imply global for new searches

"""""""""""""
" Indenting "
"""""""""""""

" When auto-indenting, use the indenting format of the previous line
set copyindent
" When on, a <Tab> in front of a line inserts blanks according to 'shiftwidth'.
" 'tabstop' is used in other places. A <BS> will delete a 'shiftwidth' worth of
" space at the start of the line.
set smarttab
" Copy indent from current line when starting a new line (typing <CR> in Insert
" mode or when using the "o" or "O" command)
set autoindent
" Automatically inserts one extra level of indentation in some cases, and works
" for C-like files
set smartindent

"""""""""
" Theme "
"""""""""

syntax enable
"set background=dark "uncomment this if your terminal has a dark background

"""""""""""""""""""""
" Language-Specific "
"""""""""""""""""""""

" load the plugin and indent settings for the detected filetype
filetype plugin indent on

" Thorfile, Rakefile, Vagrantfile and Gemfile are Ruby
au BufRead,BufNewFile {Gemfile,Rakefile,Vagrantfile,Thorfile,config.ru} set ft=ruby
au BufRead,BufNewFile *.html.erb set ft=eruby

" Add json syntax highlighting
au BufNewFile,BufRead *.json set ft=json syntax=javascript
