#!/usr/bin/env bash
# シャットダウン前の棚卸し：ワークツリーの状態、エージェントやエディタのプロセス、Orca の端末を一覧にする
echo "## ワークツリー（未コミット / 未 push / Orca のコメント）"
# 「パス<TAB>コメント」の組にする（コメントはワークツリーの行のあとに出る）
orca worktree list 2>/dev/null | awk '
  /^[0-9a-f-]+::/ { if (wt) print wt "\t" c; wt = $NF; c = "" }
  /^comment: / { sub(/^comment: /, ""); c = $0 }
  END { if (wt) print wt "\t" c }' | while IFS=$'\t' read -r wt comment; do
  [ -d "$wt" ] || continue
  dirty=$(git -C "$wt" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  ahead=$(git -C "$wt" rev-list --count @{u}..HEAD 2>/dev/null || echo "上流なし")
  branch=$(git -C "$wt" branch --show-current 2>/dev/null)
  echo "- $wt [$branch] 未コミット:$dirty 未push:$ahead"
  [ -n "$comment" ] && echo "    コメント: $comment"
done

echo; echo "## Orca の端末"
orca terminal list 2>/dev/null | grep -E "^term_" | cut -c1-160

# 監視するプロセス名は HANDOFF_PROCS で足せる（例: HANDOFF_PROCS="Unity Blender"）
procs="opencode codex claude ${HANDOFF_PROCS:-}"
echo; echo "## プロセス（$procs）"
if command -v powershell.exe >/dev/null 2>&1 || command -v pwsh >/dev/null 2>&1; then
  pwsh -NoProfile -Command "Get-Process $(echo $procs | tr " " ",") -ErrorAction SilentlyContinue | Select-Object Name,Id,StartTime | Format-Table -AutoSize | Out-String -Width 160" 2>/dev/null
else
  ps -eo pid,lstart,comm | grep -Ei "$(echo $procs | tr " " "|")" | grep -v grep
fi
