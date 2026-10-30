#!/usr/bin/env bash
# 段階表が今のモデル一覧に追いついているかを見る。ネットワークには出ない。
# 更新日は分担の変更でも新しくなるので、段階表に名前のないモデルと調査日で判定する。
# 「要調査: はい」なら agent-models-refresh の「自動で調べるとき」に進む。
models=$(timeout 20 opencode models 2>/dev/null | grep -i deepseek || true)
PY=$(command -v python3 || command -v python)
OPENCODE_MODELS="$models" PYTHONIOENCODING=utf-8 "$PY" - <<'PY'
import datetime
import json
import os
import re

MAX_AGE_DAYS = 7

table_path = os.path.expanduser("~/.config/agent-orchestrate/models.md")
if not os.path.exists(table_path):
    print("段階表: なし")
    print("要調査: はい")
    raise SystemExit

table = open(table_path, encoding="utf-8").read()

found = re.search(r"調査日：(\d{4}-\d{2}-\d{2})", table)
age = None
if found:
    age = (datetime.date.today() - datetime.date.fromisoformat(found.group(1))).days
print(f"調査日: {found.group(1)}（{age} 日前）" if found else "調査日: なし")

names = []
cache_path = os.path.expanduser("~/.codex/models_cache.json")
if os.path.exists(cache_path):
    cache = json.load(open(cache_path, encoding="utf-8"))
    names += [m["slug"] for m in cache.get("models", []) if m.get("visibility") == "list"]
names += os.environ.get("OPENCODE_MODELS", "").split()

missing = [name for name in names if name not in table]
print("段階表にないモデル: " + (", ".join(missing) if missing else "なし"))

needed = bool(missing) or age is None or age > MAX_AGE_DAYS
print("要調査: " + ("はい" if needed else "いいえ"))
PY
