# opencode を実装のワーカーにする

opencode は、いろいろなプロバイダーのモデルを `provider/model` の形で選べる CLI。DeepSeek のモデルを動かす実装のワーカーに使う。読むだけのレビューは、Codex の枠が尽きたときの予備にする。

## 使うモデル

**opencode で使うモデルは、上書き設定・段階表・ユーザーの指示に従う。** 結果は手順 4 のとおりに確かめる。

- `--model` は省かない。省くと opencode の既定のモデルが使われる（設定に `model` がなければ、opencode が自分で選ぶ）。使われたモデルは、`opencode run` の出力の先頭（`<エージェント> · <モデル>`）で確かめられる。
- 窓口は、落ちたり、応答しなくなったり、回数の制限に当たったりする。必ずタイムアウトを付ける。だめなら段階表の別のモデルに替える。
- 送ったコードがモデルの学習に使われることがある。公開してよいコードか分からないリポジトリでは、操作者に確認してから使う。
- 有料の DeepSeek は、データの扱いが文書で確かめられる窓口を優先する（例：OpenCode の従量課金）。操作者がクレジットを追加してキーを登録する。エージェントはキーを扱わない。登録後のモデル名は `opencode models` で確かめ、段階表に書く。
- opencode には、Codex のようなサンドボックスの記載がない。`opencode debug agents` で見ると、`build` はすべての操作が許可で、確認が要るのは `.env` の読み取りだけ。`plan` も `edit` が禁止なだけで、シェルは使える（2.2.1 で確認）。ワーカーは操作者の権限で動くので、`gh` の認証やホームのファイルにも届くものとして扱う。信頼できない人が書いた Issue は、中身を確かめてから依頼文にする。
- 公式サイトの CLI の説明には、2.2.1 にないフラグ（`run --dir`、`models --verbose`、`models --refresh`）が載っている。`--help` を正とする。

## 実装のワーカーにする

`opencode run` は TUI なしで実行して終わる。`run-opencode.sh` を通して動かし、`--model` は省かない。

```bash
bash ~/.claude/skills/agent-orchestrate/scripts/run-opencode.sh 3600 <ワークツリーのパス> --model <モデル> --format json \
  --title "#<番号> <題>" "$(cat <依頼文ファイル>)" > <ログファイル> 2>&1
```

- `run-opencode.sh <秒> <フォルダ> <opencode run の引数...>` は、フォルダに移って動かす（2.2.1 の `run` に `--dir` はない）。打ち切り時間を付け、標準入力を閉じ（開いていると入力を待って何も出さずに止まる）、`--auto` を拒否し、使える版では `--standalone` を付ける（付けないと常駐サーバーが立ち上がって残る）。
- `run_in_background: true` で動かし、完了の通知を待つ。
- ログは 1 行ずつの JSON で、各行に `sessionID` が入る。直してほしい点は `run-opencode.sh` に `-s <sessionID>` を付けて同じセッションに伝える。
- Git のワークツリーで、ファイルの編集から commit まで確認なしで進むことを確かめた（共有の `.git` がワークツリーの外にある状態で、無料の DeepSeek のモデルを使った）。`git push` と、`-s` で同じセッションを続けることも確かめた。`gh pr create` は未確認。止まったら、指揮者が PR 作成を引き受ける。2.2.1 では、`--agent plan` でのファイルの読み取り、`--format json`、`-s` での継続、打ち切りを確かめた。編集から commit までは 2.2.1 では未確認。
- Windows の Git Bash では `timeout` が効かないことがある。かかりすぎたら `opencode` のプロセスを止める。
- macOS には `timeout` がないので、`perl` の `alarm` で打ち切る。打ち切った直後は子の `opencode serve` が少し残り、すぐ終わることを確かめた。ワーカーが起動したコマンドが残るかどうかは未確認。

## 読むだけのレビューをさせる（Codex の枠が尽きたときの予備）

`--agent plan` を付けると、ファイルを編集するツールが使えない（`opencode debug agents` で確認）。ただし plan でも bash は使えるので、「編集・commit はしない」を依頼文に必ず書き、終わったら `git status` で何も変わっていないか見る。

```bash
bash ~/.claude/skills/agent-orchestrate/scripts/run-opencode.sh 600 <PR のワークツリー> --agent plan --model <モデル> \
  --title "review PR <番号>" "$(cat <依頼文ファイル>)"
```

- 依頼文には、手順 4-3 の指定（編集・commit はしない、正しさのバグだけ、重大度・ファイル:行・起きる手順で）と、差分の見方（`gh pr diff <PR>` や、読むファイル）を書く。
- フォルダは PR のブランチがチェックアウトされたワークツリーにする。ワーカーがまだ動いているワークツリーでは動かさない。
- 打ち切りの時間が切れると終了コード 124 で止まる。応答が遅い窓口でも、10 分を目安に打ち切る。Windows の Git Bash では、`timeout` が効かずに打ち切りの時間を大きく過ぎることがあった（120 秒の指定で 17 分）。終わらないときは、かかった時間を見て、`opencode` のプロセスを止める。
- `--format json` にすると、出力が 1 行ずつの JSON になり、各行に `sessionID` が入る。指摘の続きを聞くときは `-s <sessionID>` を付けて同じセッションを続ける。
- `<モデル>` は、上書き設定・段階表・ユーザーの指示で決めたモデル。`--model` は省かない。
- `--auto`（確認なしで許可する）は付けない。`run-opencode.sh` が拒否する。

許可ルールに `Bash(bash ~/.claude/skills/agent-orchestrate/scripts/run-opencode.sh *)` がなければ、操作者に追加を頼む。

指摘は Codex のレビューと同じく、そのまま信じず、該当箇所を自分で読んで本当か確かめてから直させる。
