" jj キーバインド
inoremap <silent> jj <ESC>

" 上書き前にバックアップを作らない
set nowritebackup
" 上書き前にバックアップを作らない
set nobackup
" 矩形ビジュアルモードで行末より先にカーソルを移動できるようにする
set virtualedit=block
" 挿入モードでバックスペースによる削除を許可する
set backspace=indent,eol,start
" 全角文字の設定
set ambiwidth=double
" wildmenu を有効にする(コマンドラインでファイルを選択できる)
set wildmenu

"----------------------------------------
" 検索
"----------------------------------------
" 検索時に大文字小文字を区別しない
set ignorecase
" 検索パターンが小文字のみなら区別せず、大文字を含めば区別する
set smartcase
" 検索がファイル末尾に達したら先頭に戻る
set wrapscan
" インクリメンタルサーチ(1 文字目の入力から検索を始める)
set incsearch
" 検索結果をハイライトする
set hlsearch

"----------------------------------------
" 表示
"----------------------------------------
" エラー時にビープ音を鳴らさない
set noerrorbells
" Windows パスのバックスラッシュをスラッシュとして扱う
set shellslash
" 対応する括弧をハイライトする
set showmatch matchtime=1
" インデント方式を変更する
set cinoptions+=:0
" コマンドライン領域を 2 行確保する
set cmdheight=2
" ステータスラインを常に表示する
set laststatus=2
" 入力中のコマンドを右下に表示する
set showcmd
" 省略せずに表示する
set display=lastline
" タブを ^I、行末を $ で表示する
set list
" 行末の空白を可視化する
set listchars=tab:^\ ,trail:~
" コマンドライン履歴を 10,000 件保存する
set history=10000
" コメントの文字色を水色にする
hi Comment ctermfg=3
" 挿入モードで Tab を押したらタブの代わりにスペースを入れる
set expandtab
" インデント幅
set shiftwidth=2
" Tab を押したときに挿入するスペースの幅
set softtabstop=2
" ファイル内のタブ文字の表示幅
set tabstop=2
" ツールバーを隠す
set guioptions-=T
" コピー(ヤンク)をクリップボードにも送る
set guioptions+=a
" メニューバーを隠す
set guioptions-=m
" 右スクロールバーを隠す
set guioptions+=R
" 対応する括弧をハイライトする
set showmatch
" 改行時にスマートインデントする
set smartindent
" スワップファイルを作らない
set noswapfile
" 折りたたみを無効にする(一致しない行を折りたたまない)
set nofoldenable
" ウィンドウタイトルを表示する
set title
" 行番号を表示する
set number
" ヤンクをシステムのクリップボードにもコピーする
set clipboard=unnamed,autoselect
" ESC 2 回で検索ハイライトを消す
nnoremap <Esc><Esc> :nohlsearch<CR><ESC>
" シンタックスハイライトを有効にする
syntax on
" 数値はすべて 10 進数として扱う
set nrformats=
" 矢印キーと h/l で行をまたいで移動できるようにする
set whichwrap=b,s,h,l,<,>,[,],~
" マウスでのスクロールを有効にする
set mouse=a

" .vimrc を自動で再読み込みする
augroup source-vimrc
  autocmd!
  autocmd BufWritePost *vimrc source $MYVIMRC | set foldmethod=marker
  autocmd BufWritePost *gvimrc if has('gui_running') source $MYGVIMRC
augroup END

" 改行時の自動コメントを無効にする
augroup auto_comment_off
  autocmd!
  autocmd BufEnter * setlocal formatoptions-=r
  autocmd BufEnter * setlocal formatoptions-=o
augroup END

" HTML/XML の閉じタグを自動補完する
augroup MyXML
  autocmd!
  autocmd Filetype xml inoremap <buffer> </ </<C-x><C-o>
  autocmd Filetype html inoremap <buffer> </ </<C-x><C-o>
augroup END
