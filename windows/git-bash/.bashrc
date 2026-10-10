# dotfiles で管理する Git Bash の設定。

case $- in
  *i*) ;;
  *) return ;;
esac

[ -d ./workspace ] && cd workspace

PS1='\[\e[36m\]\W \$\[\e[0m\] '

LS_COLORS='rs=0:di=01;35:'
export LS_COLORS

HISTFILE="$HOME/.bash_history"
HISTSIZE=100000
HISTFILESIZE=1000000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend

__dotfiles_history_sync() {
  history -a
}
PROMPT_COMMAND="__dotfiles_history_sync${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

if command -v fzf >/dev/null 2>&1; then
  __fzf_history() {
    local selected
    selected="$(history | sed 's/^[[:space:]]*[0-9][0-9]*[[:space:]]*//' | fzf --tac +s)" || return
    READLINE_LINE="$selected"
    READLINE_POINT=${#READLINE_LINE}
  }
  bind -x '"\C-r":__fzf_history'
fi

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi

if command -v zoxide >/dev/null 2>&1; then
  ZOXIDE_CACHE_DIR="$HOME/.cache"
  ZOXIDE_INIT="$ZOXIDE_CACHE_DIR/zoxide-init.bash"
  ZOXIDE_BIN="$(command -v zoxide)"

  if [[ ! -f "$ZOXIDE_INIT" || "$ZOXIDE_BIN" -nt "$ZOXIDE_INIT" ]]; then
    mkdir -p "$ZOXIDE_CACHE_DIR"
    zoxide init bash > "$ZOXIDE_INIT"

    # zoxide 0.10.0 は Git Bash/MSYS2 で不正な cygpath 呼び出しを生成する。
    # 該当する生成行だけを修正し、修正済みの zoxide バージョンには手を加えない。
    case "$OSTYPE" in
      msys*|cygwin*)
        sed -i \
          -e 's|\\command cygpath -w "\\builtin pwd -L"|\\command cygpath -w "$(\\builtin pwd -L)"|' \
          -e 's|\\command cygpath -w "\\builtin pwd -P"|\\command cygpath -w "$(\\builtin pwd -P)"|' \
          "$ZOXIDE_INIT"
        ;;
    esac
  fi

  source "$ZOXIDE_INIT"
fi

alias ls='ls --color=auto'
alias ll='ls -l --color=auto'
alias la='ls -la --color=auto'
alias grep='grep --color=auto'
alias lg='ls -la --color=auto | grep'
alias ..='cd ../'
alias ...='cd ../../'
alias j='z'
alias g='git'

repo_path() {
  local dir
  dir="$(ghq list | fzf)" || return
  printf '%s\n' "$(ghq root)/$dir"
}

repo() {
  local selected_repo_path
  selected_repo_path="$(repo_path)" || return
  cd "$selected_repo_path" || return
}

repo-code() {
  local selected_repo_path
  selected_repo_path="$(repo_path)" || return
  code -r "$selected_repo_path"
}

alias rc='repo-code'

ai-commit() {
  if ! command -v codex >/dev/null 2>&1; then
    echo "codex: command not found" >&2
    return 127
  fi

  if ! command -v jq >/dev/null 2>&1; then
    echo "jq: command not found" >&2
    return 127
  fi

  if git diff --cached --quiet; then
    echo "No staged changes."
    return 1
  fi

  local diff plan confirm entry msg
  local -a files

  diff="$(git diff --cached)"

  plan="$(codex exec <<EOF
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
$diff
EOF
)"

  echo "---- Proposed commit plan ----"
  echo "$plan"
  echo "------------------------------"

  read -r -p "Proceed with this plan? (y/N): " confirm
  [[ "$confirm" != "y" ]] && return 0

  echo "$plan" | jq -c '.[]' | while IFS= read -r entry; do
    msg="$(printf '%s\n' "$entry" | jq -r '.message')"
    mapfile -t files < <(printf '%s\n' "$entry" | jq -r '.files[]')

    git reset
    git add -- "${files[@]}"

    echo "Committing: $msg"
    git commit -F - <<< "$msg"
  done
}

alias dc='docker compose'
alias dcb='docker compose build'
alias dcr='docker compose restart'
alias dcu='docker compose up -d'
alias dce='docker compose exec'
alias dcd='docker compose down'

if [[ -r "$HOME/.unity/env" ]]; then
  . "$HOME/.unity/env"
fi
