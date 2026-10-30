#!/usr/bin/env bash
# Codex の読むだけのレビュー。使い方: review.sh <ワークツリー> <モデル> <依頼文ファイル>
# 結果は依頼文ファイルと同じフォルダの review-<ワークツリー名>.md に出る。
set -euo pipefail
. "$(dirname "$0")/_common.sh"
wt="$1"; model="$2"; prompt="$3"
out="$(dirname "$prompt")/review-$(basename "$wt").md"
"$(codex_bin)" exec -s read-only --ephemeral -m "$model" -C "$wt" -o "$out" - < "$prompt"
echo "--- 結果: $out"; cat "$out"
