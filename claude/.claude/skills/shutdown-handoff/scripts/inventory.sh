#!/usr/bin/env bash
# シャットダウン前の棚卸し：ワークツリーの状態、エージェントやエディタのプロセスを一覧にする
echo "## ワークツリー（未コミット / 未 push / ロックの理由）"
# ghq のリポジトリと今のリポジトリを見る。git worktree add で作ったものと、今のチェックアウトだけ出す
here=$(git rev-parse --show-toplevel 2>/dev/null)
{ ghq list -p 2>/dev/null; echo "$here"; } | while read -r repo; do
  git -C "$repo" -c core.quotepath=false worktree list --porcelain 2>/dev/null
done | awk '
  /^worktree / { if (wt) print wt "\t" c; wt = substr($0, 10); c = "" }
  /^locked/ { c = substr($0, 8); if (c == "") c = "理由なし" }
  END { if (wt) print wt "\t" c }' | sort -u | while IFS=$'\t' read -r wt lock; do
  [ -d "$wt" ] || continue
  if [ ! -f "$wt/.git" ] && [ "$wt" != "$here" ]; then continue; fi
  dirty=$(git -C "$wt" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  ahead=$(git -C "$wt" rev-list --count @{u}..HEAD 2>/dev/null || echo "上流なし")
  branch=$(git -C "$wt" branch --show-current 2>/dev/null)
  echo "- $wt [$branch] 未コミット:$dirty 未push:$ahead"
  [ -n "$lock" ] && echo "    ロック: $lock"
done

# 監視するプロセス名は HANDOFF_PROCS で足せる（例: HANDOFF_PROCS="Unity Blender"）
procs="dsh codex claude ${HANDOFF_PROCS:-}"
echo; echo "## プロセス（$procs）"
if command -v powershell.exe >/dev/null 2>&1 || command -v pwsh >/dev/null 2>&1; then
  pwsh -NoProfile -Command "Get-Process $(echo $procs | tr " " ",") -ErrorAction SilentlyContinue | Select-Object Name,Id,StartTime | Format-Table -AutoSize | Out-String -Width 160" 2>/dev/null
else
  ps -eo pid,lstart,comm | grep -Ei "$(echo $procs | tr " " "|")" | grep -v grep
  # macOS の dsh はアプリの実行ファイルで動くので、コマンド名に dsh と出ない
  pgrep -fl "dsh-desktop-host/lib/cli.js" | cut -c1-160
fi
