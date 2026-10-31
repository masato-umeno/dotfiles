#!/usr/bin/env bash
# サンドボックスなしで Codex ワーカーのセッションを続ける。操作者がサンドボックスを外すことを許したときだけ使う。
# 使い方: resume.sh <ワークツリー> <session id> <モデル> <effort> <指示ファイル>
# モデルを変えて続けられる（luna で失敗したら上位のモデルに上げる、など）。
# 結果は指示ファイルと同じフォルダの r-<ワークツリー名>.md に出る。
set -euo pipefail
wt="$1"; session="$2"; model="$3"; effort="$4"; prompt="$5"
here=$(dirname "$0")
# shellcheck source=_common.sh
. "$here/_common.sh"
require_linked_worktree "$wt"
out="$(dirname "$prompt")/r-$(basename "$wt").md"
cd "$wt"
"$(codex_bin)" exec resume -m "$model" -c model_reasoning_effort="\"$effort\"" \
  --dangerously-bypass-approvals-and-sandbox -o "$out" "$session" - < "$prompt"
echo "--- 結果: $out"; cat "$out"
