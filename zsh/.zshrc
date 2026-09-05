
#--------------------------------------------------------------------------------
# initialization
#---------------------------------------------------------------------------------
[ -d ./workspace ] && cd workspace

#--------------------------------------------------------------------------------
# Display
#--------------------------------------------------------------------------------
# only show current directory(%~) in prompt
PROMPT='%F{cyan}%1~ %#%f '
# ls coloring
# reset -> directory setting 01:Bold 35:Purple
LS_COLORS='rs=0:di=01;35:';
export LS_COLORS

#--------------------------------------------------------------------------------
# History
#--------------------------------------------------------------------------------
# history
HISTFILE=$HOME/.zsh_history # save log
HISTSIZE=100000             # size of history in memory
SAVEHIST=1000000            # size of history in disk(is $HISTFILE)
# share .zshhistory
setopt inc_append_history   # append history to the history file immediately, not when the shell exits
setopt share_history        # share history between all sessions

# search command history with Ctrl-R
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
# Complement
#--------------------------------------------------------------------------------
# enable completion
autoload -Uz compinit && compinit
# enable auto-completion
setopt auto_cd
# enable auto-completion for commands
setopt complete_in_word
# highlight completion candidates
zstyle ':completion:*:default' menu select=1
# speed up completion by caching
zstyle ':completion::complete:*' use-cache true
# ignore case when completing
# example: 'ls' and 'LS' are treated the same
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# narrow down completion
setopt list_packed
# ignore duplicates in history
setopt hist_ignore_dups
# when cd, automatically run ls
function chpwd() {
  # update terminal title
  echo -ne "\033]0;$(pwd | rev | awk -F \/ '{print "/"$1"/"$2}'| rev)\007"
  # show current directory info
  print -P "%~"
  ls
}

#--------------------------------------------------------------------------------
# Tool Path
#--------------------------------------------------------------------------------

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

#--------------------------------------------------------------------------------
# Alias
#--------------------------------------------------------------------------------
# easy to use
alias ls='ls --color=auto'
alias ll='ls -l --color=auto'
alias la='ls -la --color=auto'
alias grep='grep --color=auto'
alias lg='ls -la --color=auto | grep'
alias ..='cd ../'
alias ...='cd ../../'
alias j=z

# select a repository from ghq and return its full path
repo_path() {
  local dir
  dir="$(ghq list | fzf)" || return
  printf '%s\n' "$(ghq root)/$dir"
}

# move to a selected repository, or print the path when used in command substitution
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

# git (aliases via git-alias.sh)
alias g='git'

# generate commit messages from the staged diff and split into logical commits
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
