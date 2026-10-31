# start.sh・resume.sh・review.sh・run-codex.sh・run-dsh.sh・check-models.sh から読み込む共通の関数。

_common_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# git worktree add で作ったワークツリーでなければ止める。メインのチェックアウトでは動かさない。
require_linked_worktree() {
  local gitdir common
  gitdir=$(git -C "$1" rev-parse --path-format=absolute --git-dir 2>/dev/null) || {
    echo "Git のワークツリーが見つからない: $1" >&2; exit 1
  }
  common=$(git -C "$1" rev-parse --path-format=absolute --git-common-dir)
  if [ "$gitdir" = "$common" ]; then
    echo "git worktree add で作ったワークツリー以外では起動しない: $1" >&2; exit 1
  fi
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

# 使う dsh を決める。DSH_BIN があればそれ。macOS の cask は dsh を PATH に入れないので、アプリの中も探す。
dsh_bin() {
  local app="/Applications/DeepSeek Harness.app/Contents/Resources/runtime/cli/bin/dsh"
  if [ -n "${DSH_BIN:-}" ]; then
    [ -x "$DSH_BIN" ] || return 127
    echo "$DSH_BIN"
  elif command -v dsh >/dev/null 2>&1; then
    command -v dsh
  elif [ -x "$app" ]; then
    echo "$app"
  else
    return 127
  fi
}

# dsh を headless で動かす。使い方: dsh_headless <秒> <dsh の引数...>
# モデルは環境変数 DSH_WORKER_MODEL、effort は DSH_WORKER_EFFORT で渡す（references/dsh-headless.patch.yml）。
dsh_headless() {
  local secs="$1" dsh; shift
  dsh=$(dsh_bin) || return 127
  DSH_TELEMETRY_DISABLED=1 with_timeout "$secs" "$dsh" --profile headless \
    --patch "$_common_dir/../references/dsh-headless.patch.yml" "$@"
}

# dsh で使えるモデルの名前を空白区切りで出す。読めなければ何も出さない。
# 一覧を出すコマンドがないので、ない名前を頼んで API のエラーから読む。モデルは動かないので料金はかからない。
dsh_models() {
  local err
  err=$(cd "${TMPDIR:-/tmp}" && DSH_WORKER_MODEL=no-such-model dsh_headless 30 list 2>&1 >/dev/null </dev/null) || true
  printf '%s\n' "$err" | sed -n 's/.*supported API model names are \(.*\), but you passed.*/\1/p' | tr -d ','
}

# 打ち切り時間つきでコマンドを動かす。切れたら終了コード 124 にする。
# macOS には timeout がないので、perl で代わりにする。ワーカーが起動したコマンドも残らないよう、プロセスグループごと止める。
with_timeout() {
  local secs="$1"; shift
  if command -v timeout >/dev/null 2>&1; then
    timeout "$secs" "$@"
  elif command -v gtimeout >/dev/null 2>&1; then
    gtimeout "$secs" "$@"
  else
    perl -e '
      my $secs = shift @ARGV;
      my $pid = fork() // die "fork できない\n";
      if (!$pid) { setpgrp(0, 0); exec { $ARGV[0] } @ARGV or die "起動できない: $ARGV[0]\n"; }
      $SIG{ALRM} = $SIG{TERM} = sub { kill "TERM", -$pid; sleep 5; kill "KILL", -$pid; exit($_[0] eq "ALRM" ? 124 : 143) };
      alarm $secs;
      waitpid($pid, 0);
      exit($? & 127 ? 128 + ($? & 127) : $? >> 8);' "$secs" "$@"
  fi
}
