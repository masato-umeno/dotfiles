#!/usr/bin/env bash
# GitHub Projects のカンバンで、Issue を指定の列に動かす（Project に入っていなければ足す）。
# 使い方: kanban.sh <owner> <Project番号> <Issue番号> <列名> [<Status フィールド名（既定: Status）>]
# Issue は、カレントディレクトリのリポジトリのものとして扱う。
# Project の項目を全件取ると GitHub の二次レート制限に当たりやすいので、Issue の側から項目を引く。
# Project・フィールド・列の ID はキャッシュする（列を足したら、キャッシュのファイルを消す）。
set -euo pipefail
owner="$1"; project="$2"; num="$3"; status="$4"; field="${5:-Status}"

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/agent-orchestrate"
cache="$cache_dir/kanban-$owner-$project-$field.tsv"
if [ ! -s "$cache" ]; then
  mkdir -p "$cache_dir"
  project_id=$(gh project view "$project" --owner "$owner" --format json -q .id)
  gh project field-list "$project" --owner "$owner" --format json \
    -q ".fields[] | select(.name == \"$field\") | .id as \$f | .options[] | [\"$project_id\", \$f, .name, .id] | @tsv" > "$cache"
fi
line=$(awk -F '\t' -v s="$status" '$3 == s' "$cache" | head -1)
[ -n "$line" ] || { echo "列が見つからない: $field / $status（キャッシュ: $cache）"; exit 1; }
project_id=$(cut -f1 <<<"$line"); field_id=$(cut -f2 <<<"$line"); opt=$(cut -f4 <<<"$line")

read -r repo_owner repo_name < <(gh repo view --json owner,name -q '"\(.owner.login) \(.name)"')
item=$(gh api graphql -f query='query($o:String!,$r:String!,$n:Int!){repository(owner:$o,name:$r){issue(number:$n){projectItems(first:20){nodes{id project{id}}}}}}' \
  -F o="$repo_owner" -F r="$repo_name" -F n="$num" \
  -q ".data.repository.issue.projectItems.nodes[] | select(.project.id == \"$project_id\") | .id")
if [ -z "$item" ]; then
  url=$(gh issue view "$num" --json url -q .url)
  item=$(gh project item-add "$project" --owner "$owner" --url "$url" --format json -q .id)
fi

gh project item-edit --project-id "$project_id" --id "$item" --field-id "$field_id" --single-select-option-id "$opt" >/dev/null
echo "#$num → $status"
