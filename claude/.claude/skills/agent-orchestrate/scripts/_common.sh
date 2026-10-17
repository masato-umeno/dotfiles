# start.sh・resume.sh から読み込む共通の関数。

# 絶対パスにする（Git Bash では C:/... の形）。比較のため小文字にする。
_abspath_lower() {
  (cd "$1" 2>/dev/null && { pwd -W 2>/dev/null || pwd; }) | tr '[:upper:]' '[:lower:]'
}

# Orca のワークツリー（~/orca/workspaces/ の下）でなければ止める。
require_orca_worktree() {
  local wt root
  wt=$(_abspath_lower "$1"); root=$(_abspath_lower ~/orca/workspaces)
  if [ -z "$wt" ] || [ -z "$root" ]; then echo "パスが見つからない: $1" >&2; exit 1; fi
  case "$wt/" in
    "$root"/*) ;;
    *) echo "Orca のワークツリー以外では起動しない: $1" >&2; exit 1 ;;
  esac
}

# 使う codex を決める。CODEX_BIN があればそれ。Windows では Codex アプリ同梱の最新版を優先する
# （winget などで入れた CLI が古いと、アプリのランタイムと合わずにサンドボックスの初期化で失敗することがある）。
codex_bin() {
  if [ -n "${CODEX_BIN:-}" ]; then echo "$CODEX_BIN"; return; fi
  local app="" f
  for f in "${LOCALAPPDATA:-/nonexistent}"/OpenAI/Codex/bin/*/codex.exe; do
    [ -f "$f" ] || continue
    if [ -z "$app" ] || [ "$f" -nt "$app" ]; then app="$f"; fi
  done
  if [ -n "$app" ]; then echo "$app"; else command -v codex; fi
}
