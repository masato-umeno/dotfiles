
#--------------------------------------------------------------------------------
# 初期化
#---------------------------------------------------------------------------------
[ -d ./workspace ] && cd workspace

#--------------------------------------------------------------------------------
# 表示
#--------------------------------------------------------------------------------
# プロンプトにはカレントディレクトリ(%~)だけを表示する
PROMPT='%F{cyan}%1~ %#%f '
# ls の色付け
# リセット -> ディレクトリの設定 01:太字 35:紫
LS_COLORS='rs=0:di=01;35:';
export LS_COLORS

#--------------------------------------------------------------------------------
# 履歴
#--------------------------------------------------------------------------------
# 履歴
HISTFILE=$HOME/.zsh_history # 保存先
HISTSIZE=100000             # メモリ上の履歴件数
SAVEHIST=1000000            # ディスク上の履歴件数($HISTFILE)
# .zsh_history を共有する
setopt inc_append_history   # シェル終了時ではなく即座に履歴ファイルへ追記する
setopt share_history        # すべてのセッションで履歴を共有する

# Ctrl-R でコマンド履歴を検索する
if command -v fzf >/dev/null 2>&1; then
  fzf-history-widget() {
    local selected
    local -a parts
    local token
    local output=""

    selected=$(fc -rl 1 \
      | sed 's/^[[:space:]]*[0-9]\+[[:space:]]*//' \
      | fzf --tac +s) || return

    parts=(${(z)selected})
    (( ${#parts[@]} > 1 )) || return

    for token in "${parts[@]:1}"; do
      if [[ -n "$output" ]]; then
        output+=" "
      fi

      case "$token" in
        '|'|'||'|'&'|'&&'|';'|';;'|';&'|';;&'|'(' | ')'|'<'|'>'|'<<'|'>>'|'<<<'|'<&'|'>&'|'<>'|'>|')
          output+="$token"
          ;;
        *)
          output+="${(q-)${(Q)token}}"
          ;;
      esac
    done

    LBUFFER+="$output"
  }

  zle -N fzf-history-widget
  bindkey '^R' fzf-history-widget
fi

#--------------------------------------------------------------------------------
# 補完
#--------------------------------------------------------------------------------
# 補完を有効にする
autoload -Uz compinit && compinit
# 自動補完を有効にする
setopt auto_cd
# コマンドの自動補完を有効にする
setopt complete_in_word
# 補完候補をハイライトする
zstyle ':completion:*:default' menu select=1
# キャッシュで補完を高速化する
zstyle ':completion::complete:*' use-cache true
# 補完時に大文字小文字を区別しない
# 例: 'ls' と 'LS' を同じものとして扱う
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# 補完候補を絞り込む
setopt list_packed
# 履歴の重複を無視する
setopt hist_ignore_dups
# cd したら自動で ls を実行する
function chpwd() {
  # ターミナルのタイトルを更新する
  echo -ne "\033]0;$(pwd | rev | awk -F \/ '{print "/"$1"/"$2}'| rev)\007"
  # カレントディレクトリの情報を表示する
  print -P "%~"
  ls
}

#--------------------------------------------------------------------------------
# ツールのパス
#--------------------------------------------------------------------------------

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

#--------------------------------------------------------------------------------
# エイリアス
#--------------------------------------------------------------------------------
# 便利系
alias ls='ls --color=auto'
alias ll='ls -l --color=auto'
alias la='ls -la --color=auto'
alias grep='grep --color=auto'
alias lg='ls -la --color=auto | grep'
alias ..='cd ../'
alias ...='cd ../../'
alias j=z

# ghq からリポジトリを選び、そのフルパスを返す
repo_path() {
  local dir
  dir="$(ghq list | fzf)" || return
  printf '%s\n' "$(ghq root)/$dir"
}

# 選んだリポジトリへ移動する。コマンド置換で使われた場合はパスを出力する
repo() {
  local selected_repo_path
  selected_repo_path="$(repo_path)" || return

  if [[ -t 1 ]]; then
    cd "$selected_repo_path" || return
    return
  fi

  printf '%s\n' "$selected_repo_path"
}

repo-code() {
  code -r "$(repo)"
}

alias rc='repo-code'

# git(エイリアスは git-alias.sh 経由)
alias g='git'

# ステージ済みの差分からコミットメッセージを生成し、論理的な単位のコミットに分割する
ai-commit() {
  if ! command -v codex >/dev/null 2>&1; then
    echo "codex: command not found" >&2
    return 127
  fi

  if git diff --cached --quiet; then
    echo "No staged changes."
    return 1
  fi

  DIFF=$(git diff --cached)

  PLAN=$(codex exec <<EOF
Analyze the following git diff and split it into logical commits.

Return JSON:
[
  {
    "message": "...",
    "files": ["..."]
  }
]

Rules:
- Use Conventional Commits
- Group by logical concern
- Avoid mixing unrelated changes

Diff:
$DIFF
EOF
)

  echo "---- Proposed commit plan ----"
  echo "$PLAN"
  echo "------------------------------"

  read "CONFIRM?Proceed with this plan? (y/N): "
  [[ "$CONFIRM" != "y" ]] && return 0

  echo "$PLAN" | jq -c '.[]' | while read -r entry; do
    MSG=$(echo "$entry" | jq -r '.message')
    FILES=$(echo "$entry" | jq -r '.files[]')

    git reset
    git add $FILES

    echo "Committing: $MSG"
    git commit -F - <<< "$MSG"
  done
}

# docker
alias dc='docker compose'
alias dcb='docker compose build'
alias dcr='docker compose restart'
alias dcu='docker compose up -d'
alias dce='docker compose exec'
alias dcd='docker compose down'

# Unity CLI
if [[ -r "$HOME/.unity/env" ]]; then
  . "$HOME/.unity/env"
fi
