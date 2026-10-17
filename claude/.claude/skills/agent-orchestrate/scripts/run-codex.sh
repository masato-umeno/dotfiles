#!/usr/bin/env bash
# 予備の起動方法。使い方: run-codex.sh <ワークツリー> <モデル> <effort> <依頼文ファイル>
# 結果は依頼文ファイルと同じフォルダの r-<ワークツリー名>.md に出る。
set -euo pipefail
wt="$1"; model="$2"; effort="$3"; prompt="$4"
# Orca のワークツリーが共有する .git はワークツリーの外にあるので、書き込み先として渡す
gitdir=$(git -C "$wt" rev-parse --path-format=absolute --git-common-dir)
out="$(dirname "$prompt")/r-$(basename "$wt").md"
codex exec -m "$model" -c model_reasoning_effort="$effort" \
  -c sandbox_workspace_write.network_access=true --approve-for-me \
  --add-dir "$gitdir" \
  -C "$wt" -o "$out" - < "$prompt"
echo "--- 結果: $out"; cat "$out"
