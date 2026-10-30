# CLAUDE.md

エージェント向けのガイドは AGENTS.md にまとめている。

@AGENTS.md

## Claude Code

- `claude/.claude/` の変更は、リンクしている環境の `~/.claude/` にすぐ反映される。スキルやスクリプトを変えたら、次の呼び出しで壊れないように、その場で動かして確かめる。
- Claude Code は `settings.json` を書き換えることがある。コミット前に差分の中身を確かめる。
- 必ず止めたい操作は指示文に頼らず、`settings.json` の deny や hooks に書く。指示文は強制にならない。
