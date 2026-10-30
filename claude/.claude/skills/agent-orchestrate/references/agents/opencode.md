# opencode を実装のワーカーにする

opencode は、いろいろなプロバイダーのモデルを `provider/model` の形で選べる CLI。DeepSeek のモデルを動かす実装のワーカーに使う。読むだけのレビューは、Codex の枠が尽きたときの予備にする。

## 使うモデル（既定は無料のモデルだけ）

**opencode で使うモデルは、上書き設定・段階表・ユーザーの指示に従う。指定がなければ、無料のモデルだけ使う。** 期間限定・回数制限などの条件つきで 0 円のものも、指定がなければ「無料のうちだけ使う」。条件が切れたら使うのをやめ、段階表の別のモデルに替える。

無料のモデルは、調査や読むだけのレビュー、小さい Issue の実装に回してよい。結果は Codex のときと同じように確かめる（手順 4）。

- どのモデルが無料で、いつまで無料かは、このスキルには書かない（変わるので）。ユーザーのメモリか、各リポジトリの `.agents/agent-orchestrate.md` を見る。
- CLI での確かめ方：`opencode models <provider> --verbose --refresh` で、各モデルの `cost` の `input` と `output` がどちらも 0 なら、無料の候補になる。ただしこれはモデル一覧の情報で、期限や回数の条件、実際に請求されないかまでは分からない（未確認）。メモリにも上書き設定にもなく、`cost` だけでは決めきれないときは、操作者に聞く。
- `--model` は省かない。省くと opencode の既定のモデルが使われ、それが無料とは限らない（設定に `model` がなければ、opencode が自分で選ぶ）。使われたモデルは、`opencode run` の出力の先頭（`<エージェント> · <モデル>`）で確かめられる。
- 無料の窓口は、落ちたり、応答しなくなったり、回数の制限に当たったりする。必ずタイムアウトを付ける。だめなら段階表の別のモデルに替える。
- 送ったコードがモデルの学習に使われることがある。公開してよいコードか分からないリポジトリでは、操作者に確認してから使う。
- 有料の DeepSeek は、データの扱いが文書で確かめられる窓口を優先する（例：OpenCode の従量課金）。操作者がクレジットを追加してキーを登録する。エージェントはキーを扱わない。登録後のモデル名は `opencode models <provider>` で確かめ、段階表に書く。

## 実装のワーカーにする

`opencode run` は TUI なしで実行して終わる。`--model` は省かず、`--auto` も付けない。

```bash
timeout 3600 opencode run --model <モデル> --dir <ワークツリーのパス> --format json \
  --title "#<番号> <題>" "$(cat <依頼文ファイル>)" < /dev/null > <ログファイル> 2>&1
```

- `< /dev/null` は省かない。標準入力が開いていると、入力を待って何も出さずに止まる。
- `run_in_background: true` で動かし、完了の通知を待つ。
- ログは 1 行ずつの JSON で、各行に `sessionID` が入る。直してほしい点は `opencode run -s <sessionID>` で同じセッションに伝える。
- Git のワークツリーで、ファイルの編集から commit まで確認なしで進むことを確かめた（共有の `.git` がワークツリーの外にある状態で、無料の DeepSeek のモデルを使った）。`git push` と、`-s` で同じセッションを続けることも確かめた。`gh pr create` は未確認。止まったら、指揮者が PR 作成を引き受ける。
- Windows の Git Bash では `timeout` が効かないことがある。かかりすぎたら `opencode` のプロセスを止める。

## Orca の監督つきワーカーにする

Orca の画面で様子を見たいときの方法。最後まで動くかは未確認なので、基本は上の `opencode run` を使う。

`orca orchestration worker-start` の `--agent` は `opencode` を受け付ける（`orca agent-context --json` と `orca skills get orchestration --full` で確認）。ほかに `opencode2` という ID もあるが、違いは未確認。

**アカウントを選ぶ。** OpenCode のアカウント（プロファイル）は、新しく起動するエージェントに使われる。

```bash
orca account list --agent opencode
orca account select --agent opencode --account <ID または system>
```

`system` は、Orca が管理するプロファイルではなく、この PC の opencode 自身の認証を使う指定と思われる（未確認）。アカウントの追加（`orca account add --agent opencode`）はサインインが要るので、操作者にしてもらう。

**起動する。** モデルは必ず指定する（「使うモデル」を参照）。新しいワークツリーとモデルの指定は同時にできない（`--worktree new-top-level` に `--model` は付けられない）ので、先にワークツリーを作り、そこを選んで起動する。`--effort` は opencode では使えない。`<モデル>` は、上書き設定・段階表・ユーザーの指示で決めたモデル、指定がなければ無料のモデル（`provider/model` の形）。

```bash
orca worktree create --name issue-<番号> --base-branch origin/<base> --issue <番号> --setup skip \
  --comment "OpenCode(<モデル>) に委任" --json
orca orchestration worker-start --spec "<依頼文>" --task-title "#<番号> <題>" \
  --worktree path:<ワークツリーのパス> --agent opencode --model <モデル> --json
```

- モデルの指定が通るのは、Orca がその PC の opencode の版と、モデルが使えることを確かめられたときだけ。通らなければ拒否される。返ってきた JSON の `launch.effective` を見て、実際に使われたモデルを確かめる（`launch.requested` だけで判断しない）。
- 待ち方、質問への答え方、直してほしい点の伝え方（`orchestration check`・`reply`・`send`）は Codex のワーカーと同じ。
- 未確認：opencode のワーカーが、実際に最後まで動いて `worker_done` を返すか。`opencode` の既定の build エージェントは、作業ディレクトリの外に触るときに確認を求める設定になっている。Orca のワークツリーが共有する `.git` は外にあるので、commit のときに確認で止まるかもしれない。止まったら Orca の画面で操作者に許してもらい、上書き設定に結果を書く。
- 止まったら別のモデルに替える、という手順 2 の考え方は同じ。ただし替える先も、指定がなければ無料のモデルだけ。Codex には回さない。監督つきワーカーのまま途中でモデルを替えられるかは未確認。替えられなければ、同じワークツリーで新しく起動し直す。

## 読むだけのレビューをさせる（Codex の枠が尽きたときの予備）

`--agent plan` を付けると、ファイルを編集するツールが使えない（`opencode agent list` で確認）。ただし plan でも bash は使えるので、「編集・commit はしない」を依頼文に必ず書き、終わったら `git status` で何も変わっていないか見る。

```bash
timeout 600 opencode run --agent plan --model <モデル> --dir <PR のワークツリー> \
  --title "review PR <番号>" "$(cat <依頼文ファイル>)"
```

- 依頼文には、手順 4-3 の指定（編集・commit はしない、正しさのバグだけ、重大度・ファイル:行・起きる手順で）と、差分の見方（`gh pr diff <PR>` や、読むファイル）を書く。
- `--dir` は PR のブランチがチェックアウトされたワークツリーにする。ワーカーがまだ動いているワークツリーでは動かさない。
- `timeout` が切れると終了コード 124 で止まる。応答が遅い窓口でも、10 分を目安に打ち切る。Windows の Git Bash では、`timeout` が効かずに打ち切りの時間を大きく過ぎることがあった（120 秒の指定で 17 分）。終わらないときは、かかった時間を見て、`opencode` のプロセスを止める。
- `--format json` にすると、出力が 1 行ずつの JSON になり、各行に `sessionID` が入る。指摘の続きを聞くときは `opencode run -s <sessionID> ...` で同じセッションを続ける。
- `<モデル>` は、上書き設定・段階表・ユーザーの指示で決めたモデル、指定がなければ無料のモデル。`--model` は省かない。
- `--auto`（確認なしで許可する）は付けない。

許可ルールに `Bash(timeout * opencode run *)` がなければ、操作者に追加を頼む。

指摘は Codex のレビューと同じく、そのまま信じず、該当箇所を自分で読んで本当か確かめてから直させる。
