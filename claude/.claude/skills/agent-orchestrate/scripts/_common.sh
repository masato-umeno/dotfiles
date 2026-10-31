# start.sh・resume.sh・review.sh・run-opencode.sh・check-models.sh から読み込む共通の関数。

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

# opencode 2 は既定で常駐サーバーを起動して使う。常駐を残さないよう、使える版では --standalone を付ける。
opencode_standalone() {
  case "$(opencode "$1" --help 2>&1)" in
    *--standalone*) echo --standalone ;;
  esac
}

# 打ち切り時間つきでコマンドを動かす。切れたら終了コード 124 にする。
# macOS には timeout がないので、perl の alarm で代わりにする。
with_timeout() {
  local secs="$1" rc=0; shift
  if command -v timeout >/dev/null 2>&1; then
    timeout "$secs" "$@"
  elif command -v gtimeout >/dev/null 2>&1; then
    gtimeout "$secs" "$@"
  else
    perl -e 'alarm shift @ARGV; exec { $ARGV[0] } @ARGV or die "起動できない: $ARGV[0]\n"' "$secs" "$@" || rc=$?
    if [ "$rc" -eq 142 ]; then rc=124; fi
    return "$rc"
  fi
}
