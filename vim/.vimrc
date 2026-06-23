" jj keybind
inoremap <silent> jj <ESC>

" Disable creating a backup before overwriting a file
set nowritebackup
" Disable creating a backup before overwriting a file
set nobackup
" In blockwise visual mode, allow the cursor to move past the end of the line
set virtualedit=block
" Allow deleting with backspace in insert mode
set backspace=indent,eol,start
" Settings for full-width characters
set ambiwidth=double
" Enable wildmenu (select files from the vim command bar)
set wildmenu

"----------------------------------------
" Search
"----------------------------------------
" Ignore case when searching
set ignorecase
" If search pattern contains lowercase letters, ignore case; if uppercase, be case-sensitive
set smartcase
" Wrap around when search reaches the end of file
set wrapscan
" Incremental search (search starts when the first character is typed)
set incsearch
" Highlight search results
set hlsearch

"----------------------------------------
" Display
"----------------------------------------
" Do not beep on error messages
set noerrorbells
" Treat backslashes in Windows paths as slashes
set shellslash
" Highlight matching parentheses/braces
set showmatch matchtime=1
" Change indentation style
set cinoptions+=:0
" Reserve 2 lines for the command line area
set cmdheight=2
" Always show the status line
set laststatus=2
" Show unfinished command in the bottom-right corner
set showcmd
" Display without truncation
set display=lastline
" Show tabs as ^I and EOL as $
set list
" Visualize trailing spaces at line ends
set listchars=tab:^\ ,trail:~
" Save 10,000 command-line histories
set history=10000
" Set comment text color to light blue
hi Comment ctermfg=3
" Insert spaces instead of tabs when pressing Tab in insert mode
set expandtab
" Indentation width
set shiftwidth=2
" Width of inserted space characters when pressing Tab
set softtabstop=2
" Display width of existing tab characters in file
set tabstop=2
" Hide toolbar
set guioptions-=T
" Copy (yank) also goes to clipboard
set guioptions+=a
" Hide menu bar
set guioptions-=m
" Hide right scrollbar
set guioptions+=R
" Highlight matching parentheses
set showmatch
" Smart indent when wrapping lines
set smartindent
" Do not create swap files
set noswapfile
" Disable folding (do not fold unmatched lines)
set nofoldenable
" Show the window title
set title
" Show line numbers
set number
" Yank also copies to system clipboard
set clipboard=unnamed,autoselect
" Clear search highlight with double ESC
nnoremap <Esc><Esc> :nohlsearch<CR><ESC>
" Enable syntax highlighting
syntax on
" Treat all numbers as decimal
set nrformats=
" Allow moving across lines with arrow keys and h/l
set whichwrap=b,s,h,l,<,>,[,],~
" Enable mouse scrolling
set mouse=a

" Auto reload .vimrc
augroup source-vimrc
  autocmd!
  autocmd BufWritePost *vimrc source $MYVIMRC | set foldmethod=marker
  autocmd BufWritePost *gvimrc if has('gui_running') source $MYGVIMRC
augroup END

" Disable auto comment on new lines
augroup auto_comment_off
  autocmd!
  autocmd BufEnter * setlocal formatoptions-=r
  autocmd BufEnter * setlocal formatoptions-=o
augroup END

" Auto-complete closing tags in HTML/XML
augroup MyXML
  autocmd!
  autocmd Filetype xml inoremap <buffer> </ </<C-x><C-o>
  autocmd Filetype html inoremap <buffer> </ </<C-x><C-o>
augroup END
