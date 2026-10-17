# opencode をワーカー・レビュー役にする

opencode は、いろいろなプロバイダーのモデルを `provider/model` の形で選べる CLI。Codex の枠を節約したいときに、実装のワーカーや読むだけのレビュー役に回す。

## 無料のモデルを使う

無料で使えるモデルがあれば、調査や読むだけのレビュー、小さい Issue の実装に回してよい。結果は Codex のときと同じように確かめる（手順 4）。

- どのモデルが無料で、いつまで使えるかは、このスキルには書かない。ユーザーのメモリか、各リポジトリの `.agents/agent-orchestrate.md` を見る。どちらにもなければ操作者に聞く。
- 使えるモデルは `opencode models [provider]` で、料金の情報は `--verbose` で見られる。無料の期間が終わっていることがあるので、使う前に確かめる。
- 無料の窓口は、落ちたり、応答しなくなったり、回数の制限に当たったりする。必ずタイムアウトを付ける。だめなら Codex に戻す。
- 送ったコードがモデルの学習に使われることがある。公開してよいコードか分からないリポジトリでは、操作者に確認してから使う。

## Orca の監督つきワーカーにする

`orca orchestration worker-start` の `--agent` は `opencode` を受け付ける（`orca agent-context --json` と `orca skills get orchestration --full` で確認）。ほかに `opencode2` という ID もあるが、違いは未確認。

**アカウントを選ぶ。** OpenCode のアカウント（プロファイル）は、新しく起動するエージェントに使われる。

```bash
orca account list --agent opencode
orca account select --agent opencode --account <ID または system>
```

`system` は、Orca が管理するプロファイルではなく、この PC の opencode 自身の認証を使う指定と思われる（未確認）。アカウントの追加（`orca account add --agent opencode`）はサインインが要るので、操作者にしてもらう。

**モデルを指定しないとき**は、Codex と同じく `--worktree new-top-level` で新しいワークツリーごと起動できる。opencode の設定にある既定のモデルが使われる。

```bash
orca orchestration worker-start --spec "<依頼文>" --task-title "#<番号> <題>" \
  --worktree new-top-level --name issue-<番号> --base-branch origin/<base> --setup skip \
  --agent opencode --json
```

**モデルを指定するとき**は、先にワークツリーを作り、そこを選んで起動する。新しいワークツリーとモデルの指定は同時にできない。`--effort` は opencode では使えない。

```bash
orca worktree create --name issue-<番号> --base-branch origin/<base> --issue <番号> --setup skip \
  --comment "OpenCode(<provider/model>) に委任" --json
orca orchestration worker-start --spec "<依頼文>" --task-title "#<番号> <題>" \
  --worktree path:<ワークツリーのパス> --agent opencode --model <provider/model> --json
```

- モデルの指定が通るのは、Orca がその PC の opencode の版と、モデルが使えることを確かめられたときだけ。通らなければ拒否される。返ってきた JSON の `launch.effective` を見て、実際に使われたモデルを確かめる（`launch.requested` だけで判断しない）。
- 待ち方、質問への答え方、直してほしい点の伝え方（`orchestration check`・`reply`・`send`）は Codex のワーカーと同じ。
- 未確認：opencode のワーカーが、実際に最後まで動いて `worker_done` を返すか。`opencode` の既定の build エージェントは、作業ディレクトリの外に触るときに確認を求める設定になっている。Orca のワークツリーが共有する `.git` は外にあるので、commit のときに確認で止まるかもしれない。止まったら Orca の画面で操作者に許してもらい、上書き設定に結果を書く。
- 安いモデルで止まったら上のモデルに上げる、という手順 2 の考え方は同じ。監督つきワーカーのまま途中でモデルを替えられるかは未確認。替えられなければ、同じワークツリーで新しく起動し直す。

## 読むだけのレビューをさせる

`opencode run` は、1 回の依頼を TUI なしで実行して終わる。`--agent plan` を付けると、ファイルを編集するツールが使えない（`opencode agent list` で確認）。ただし plan でも bash は使えるので、「編集・commit はしない」を依頼文に必ず書き、終わったら `git status` で何も変わっていないか見る。

```bash
timeout 600 opencode run --agent plan --model <provider/model> --dir <PR のワークツリー> \
  --title "review PR <番号>" "$(cat <依頼文ファイル>)"
```

- 依頼文には、手順 4-3 の指定（編集・commit はしない、正しさのバグだけ、重大度・ファイル:行・起きる手順で）と、差分の見方（`gh pr diff <PR>` や、読むファイル）を書く。
- `--dir` は PR のブランチがチェックアウトされたワークツリーにする。ワーカーがまだ動いているワークツリーでは動かさない。
- `timeout` が切れると終了コード 124 で止まる。応答が遅い窓口でも、10 分を目安に打ち切る。
- `--format json` にすると、出力が 1 行ずつの JSON になり、各行に `sessionID` が入る。指摘の続きを聞くときは `opencode run -s <sessionID> ...` で同じセッションを続ける。
- `--model` を省くと、opencode の設定にある既定のモデルが使われる。
- `--auto`（確認なしで許可する）は付けない。

許可ルールに `Bash(timeout * opencode run *)` がなければ、操作者に追加を頼む。

指摘は Codex のレビューと同じく、そのまま信じず、該当箇所を自分で読んで本当か確かめてから直させる。
