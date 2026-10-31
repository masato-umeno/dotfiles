#!/usr/bin/env bash
# dsh のワーカーを打ち切り時間つきで動かす。使い方: run-dsh.sh <秒> <ワークツリー> <モデル> <依頼文ファイル> [session id]
# session id を付けると、同じワークツリーのセッションを続ける。
# 依頼文ファイルと同じフォルダに、イベントのログ w-<ワークツリー名>.jsonl と最後の返答 r-<ワークツリー名>.md が出る。
# 終了コードは dsh のまま（0 は完了、1 は失敗や中止）。打ち切りは 124、dsh がないときは 127、使えないモードは 2。
# 既定の workspace-write は、git worktree add で作ったワークツリーでしか動かさない。
# DSH_PERMISSION_MODE=read-only なら、書き込めないのでどのフォルダでも動かせる。ほかのモードは拒否する。
set -euo pipefail
. "$(dirname "$0")/_common.sh"
secs="$1"; wt="$2"; model="$3"; prompt="$4"; session="${5:-}"
export DSH_PERMISSION_MODE="${DSH_PERMISSION_MODE:-workspace-write}"
case "$DSH_PERMISSION_MODE" in
  workspace-write) require_linked_worktree "$wt" ;;
  read-only) ;;
  *) echo "run-dsh.sh: $DSH_PERMISSION_MODE では動かさない" >&2; exit 2 ;;
esac
dsh_bin >/dev/null || { echo "run-dsh.sh: dsh がない" >&2; exit 127; }
PY=$(command -v python3 || command -v python) || { echo "run-dsh.sh: python がない" >&2; exit 1; }

wt=$(cd "$wt" && pwd)
prompt="$(cd "$(dirname "$prompt")" && pwd)/$(basename "$prompt")"
log="$(dirname "$prompt")/w-$(basename "$wt").jsonl"
result="$(dirname "$prompt")/r-$(basename "$wt").md"

# ワーカーが誤って GitHub を操作しないよう、gh と Git の認証を見えなくする。
# サンドボックスはネットワークと keyring を止めないので、これは境界ではない（references/agents/dsh.md）。
GH_CONFIG_DIR=$(mktemp -d)
export GH_CONFIG_DIR
trap 'rmdir "$GH_CONFIG_DIR"' EXIT
unset GH_TOKEN GITHUB_TOKEN SSH_AUTH_SOCK

export DSH_WORKER_MODEL="$model"
cd "$wt"
rc=0
dsh_headless "$secs" --json ${session:+--session-id "$session"} - < "$prompt" > "$log" || rc=$?

session=$("$PY" - "$log" "$result" <<'PY'
import json
import sys

session = final = ""
for line in open(sys.argv[1], encoding="utf-8"):
    try:
        event = json.loads(line)
    except ValueError:
        continue
    if event.get("type") == "session":
        session = event.get("sessionId", "")
    elif event.get("type") == "final":
        final = event.get("text", "")
open(sys.argv[2], "w", encoding="utf-8").write(final + "\n")
print(session)
PY
)
echo "--- 結果: 終了コード $rc、session $session"
echo "--- ログ: $log"
echo "--- 返答: $result"
cat "$result"
exit "$rc"
