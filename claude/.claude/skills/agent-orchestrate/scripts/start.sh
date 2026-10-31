#!/usr/bin/env bash
# サンドボックスなしで Codex ワーカーを新しく起動する。操作者がサンドボックスを外すことを許したときだけ使う。
# 使い方: start.sh <ワークツリー> <モデル> <effort> <依頼文ファイル>
# 結果は依頼文ファイルと同じフォルダの r-<ワークツリー名>.md に出る。
# git worktree add で作ったワークツリー以外では起動しない。
set -euo pipefail
wt="$1"; model="$2"; effort="$3"; prompt="$4"
here=$(dirname "$0")
# shellcheck source=_common.sh
. "$here/_common.sh"
require_linked_worktree "$wt"
out="$(dirname "$prompt")/r-$(basename "$wt").md"
"$(codex_bin)" exec -m "$model" -c model_reasoning_effort="\"$effort\"" \
  --dangerously-bypass-approvals-and-sandbox -C "$wt" -o "$out" - < "$prompt"
echo "--- 結果: $out"; cat "$out"
