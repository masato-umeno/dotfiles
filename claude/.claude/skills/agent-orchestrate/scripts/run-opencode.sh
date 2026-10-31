#!/usr/bin/env bash
# opencode run を打ち切り時間つきで動かす。使い方: run-opencode.sh <秒> <フォルダ> <opencode run の引数...>
# opencode 2 の run に --dir はないので、フォルダに移ってから動かす。
# 標準入力が開いていると opencode が止まるので閉じる。確認なしで許可する --auto は通さない。
set -euo pipefail
. "$(dirname "$0")/_common.sh"
secs="$1"; dir="$2"; shift 2
for arg in "$@"; do
  case "$arg" in
    --auto|--auto=*) echo "run-opencode.sh: --auto は使わない" >&2; exit 2 ;;
  esac
done
if ! command -v opencode >/dev/null 2>&1; then
  echo "run-opencode.sh: opencode がない" >&2; exit 127
fi
standalone=$(opencode_standalone run)
cd "$dir"
with_timeout "$secs" opencode run ${standalone:+"$standalone"} "$@" < /dev/null
