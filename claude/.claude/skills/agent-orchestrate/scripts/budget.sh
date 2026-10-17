#!/usr/bin/env bash
# Codex の利用枠を表示する。最近のセッションログの中から、最も新しい「codex」枠の記録を探す
# （limit_id が premium などの記録は中身が空のことがあるので使わない）
PYTHONIOENCODING=utf-8 python - <<'PY'
import glob, json, os, datetime
files = sorted(glob.glob(os.path.expanduser("~/.codex/sessions/*/*/*/*.jsonl")),
               key=os.path.getmtime, reverse=True)[:30]
best = None  # (タイムスタンプ, rate_limits)
for f in files:
    for line in open(f, encoding="utf-8", errors="ignore"):
        if '"rate_limits"' not in line:
            continue
        try:
            d = json.loads(line)
        except Exception:
            continue
        ts = d.get("timestamp", "")
        stack = [d]
        while stack:
            x = stack.pop()
            if isinstance(x, dict):
                rl = x.get("rate_limits")
                if isinstance(rl, dict) and rl.get("limit_id") == "codex" and rl.get("primary"):
                    if best is None or ts > best[0]:
                        best = (ts, rl)
                stack.extend(x.values())
            elif isinstance(x, list):
                stack.extend(x)
if not best:
    print("codex 枠の記録が見つからない"); raise SystemExit
ts, rl = best
print(f"記録時刻: {ts}")
for k, label in (("primary", "5時間枠"), ("secondary", "週の枠")):
    w = rl.get(k) or {}
    r = w.get("resets_at")
    when = datetime.datetime.fromtimestamp(r).strftime("%m/%d %H:%M") if r else "?"
    print(f"{label}: {w.get('used_percent', '?')}% 使用（リセット {when}）")
PY
