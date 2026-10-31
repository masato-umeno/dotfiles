#!/usr/bin/env bash
# 段階表が今のモデル一覧に追いついているかを見る。dsh の一覧はエラーの応答から、Codex の一覧は手元のキャッシュから読む。
# 更新日は分担の変更でも新しくなるので、段階表に名前のないモデルと調査日で判定する。
# 「要調査: はい」なら agent-models-refresh の「自動で調べるとき」に進む。
# 一覧を読めなければ「読めない一覧」に出して、終了コード 1 にする。追いついているとは言わない。
. "$(dirname "$0")/_common.sh"
models=$(dsh_models)
PY=$(command -v python3 || command -v python) || { echo "check-models.sh: python がない" >&2; exit 1; }
DSH_MODELS="$models" PYTHONIOENCODING=utf-8 "$PY" - <<'PY'
import datetime
import json
import os
import re

MAX_AGE_DAYS = 7

names = []
unreadable = []

dsh_names = os.environ.get("DSH_MODELS", "").split()
if dsh_names:
    print("dsh のモデル: " + ", ".join(dsh_names))
    names += dsh_names
else:
    unreadable.append("dsh")

try:
    cache_path = os.path.expanduser("~/.codex/models_cache.json")
    cache = json.load(open(cache_path, encoding="utf-8"))
    codex_names = [m["slug"] for m in cache["models"] if m["visibility"] == "list"]
except (OSError, ValueError, KeyError, TypeError):
    codex_names = []
if codex_names:
    names += codex_names
else:
    unreadable.append("Codex")

if unreadable:
    print("読めない一覧: " + ", ".join(unreadable))
status = 1 if unreadable else 0

table_path = os.path.expanduser("~/.config/agent-orchestrate/models.md")
if not os.path.exists(table_path):
    print("段階表: なし")
    print("要調査: はい")
    raise SystemExit(status)

table = open(table_path, encoding="utf-8").read()

found = re.search(r"調査日：(\d{4}-\d{2}-\d{2})", table)
age = None
if found:
    age = (datetime.date.today() - datetime.date.fromisoformat(found.group(1))).days
print(f"調査日: {found.group(1)}（{age} 日前）" if found else "調査日: なし")

# 部分一致だと、段階表の deepseek-v9-pro で deepseek-v9 を見落とす。名前全体で比べる。
tokens = set(re.findall(r"[A-Za-z0-9](?:[A-Za-z0-9._/:-]*[A-Za-z0-9])?", table))
tokens |= {token.rsplit("/", 1)[-1] for token in tokens}
missing = [name for name in names if name.rsplit("/", 1)[-1] not in tokens]
print("段階表にないモデル: " + (", ".join(missing) if missing else "なし"))

needed = bool(missing) or age is None or age > MAX_AGE_DAYS
print("要調査: " + ("はい" if needed else "不明" if unreadable else "いいえ"))
raise SystemExit(status)
PY
