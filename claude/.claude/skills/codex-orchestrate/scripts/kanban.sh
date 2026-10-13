#!/usr/bin/env bash
# GitHub Projects のカンバンで、Issue を指定の列に動かす（Project に入っていなければ足す）。
# 使い方: kanban.sh <owner> <Project番号> <Issue番号> <列名> [<Status フィールド名（既定: Status）>]
# Issue は、カレントディレクトリのリポジトリのものとして扱う。
set -euo pipefail
owner="$1"; project="$2"; num="$3"; status="$4"; field="${5:-Status}"

project_id=$(gh project view "$project" --owner "$owner" --format json -q .id)
read -r field_id opt < <(gh project field-list "$project" --owner "$owner" --format json \
  -q ".fields[] | select(.name == \"$field\") | [.id, (.options[] | select(.name == \"$status\") | .id)] | @tsv")
[ -n "${opt:-}" ] || { echo "列が見つからない: $field / $status"; exit 1; }

url=$(gh issue view "$num" --json url -q .url)
item=$(gh project item-list "$project" --owner "$owner" --format json -L 1000 \
  -q ".items[] | select(.content.url == \"$url\") | .id")
[ -n "$item" ] || item=$(gh project item-add "$project" --owner "$owner" --url "$url" --format json -q .id)

gh project item-edit --project-id "$project_id" --id "$item" --field-id "$field_id" --single-select-option-id "$opt" >/dev/null
echo "#$num → $status"
