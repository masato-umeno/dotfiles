# dsh を実装のワーカーにする

`dsh` は DeepSeek Harness の CLI。`--profile headless` で 1 つの依頼を実行して終わる。実装のワーカーに使い、読むだけのレビューは Codex の枠が尽きたときの予備にする。ここに書いた挙動は macOS の 0.2.1-rc.5 で確かめた。版が変わったら `dsh --profile headless --help` を正とする。

## 準備

- `brew install --cask deepseek-harness` はアプリだけを入れ、`dsh` を PATH に入れない。本体はアプリの中の `Contents/Resources/runtime/cli/bin/dsh` にある。`scripts/_common.sh` の `dsh_bin` は `DSH_BIN`、PATH、アプリの中の順に探すので、`run_in_background` や非対話シェルでも見つかる。対話シェルは `zsh/.zprofile` が PATH に足す。
- 認証は DeepSeek Harness のアプリでログインしたアカウントを使う。headless は既定で保存済みの認証を読まない（`MISSING_CREDENTIAL` で止まる）ので、公式の手順どおり `references/dsh-headless.patch.yml` を `--patch` で足す。`run-dsh.sh` が付ける。`ACCOUNT_SIGN_IN_REQUIRED` が出たら、操作者にアプリでログインし直してもらう。
- 残高はアプリの設定の Account の画面で見る。CLI からは読めない。使った分はここから引かれ、尽きると `ACCOUNT_QUOTA` で止まる（公式の文書で確認。実際に尽きた場合は未確認）。操作者に残高を見てもらい、段階表の「課金状況」に書く。
- API キーで動かすこともできる（環境変数か `~/.dsh/.env` の `DEEPSEEK_API_KEY`、`provider: deepseek-official`）。キーは操作者が登録し、エージェントは扱わない。この経路は未確認。

## 動かす

```bash
bash ~/.claude/skills/agent-orchestrate/scripts/run-dsh.sh 3600 <ワークツリーのパス> <モデル> <依頼文ファイル> [session id]
```

- `run_in_background: true` で動かし、完了の通知を待つ。
- 依頼文ファイルと同じフォルダに、イベントのログ `w-<ワークツリー名>.jsonl` と最後の返答 `r-<ワークツリー名>.md` が出る。同じワークツリーをもう一度動かすと上書きされる。
- 終了コードは次のとおり。

| コード | 意味 | 次にすること |
|---|---|---|
| 0 | 完了 | 最終報告と差分を確かめる。0 でも依頼どおりとは限らない |
| 1 | 失敗や中止 | 標準エラーの `dsh: <コード>: <内容>` とログの最後を見る。`ACCOUNT_QUOTA` は残高切れなので、操作者に伝えて止める |
| 2 | 使えないモード | `DSH_PERMISSION_MODE` を見直す |
| 124 | 打ち切り | 同じ session id で続ける（下の「続ける」） |
| 127 | dsh がない | インストールと `DSH_BIN` を確かめる |

- ログは 1 行ずつの JSON で、`session` から始まり `final` で終わる。間に `status`・`thinking`・`text`・`tool_call`・`tool_result` が入る。`final` 以外は 8KiB で切られるので、完全な記録ではない。読んだファイルの中身が入るので、リポジトリに入れない。
- モデルの一覧は `check-models.sh` の「dsh のモデル」で分かる。ない名前を指定すると、`INVALID_REQUEST` で止まる。

## 続ける

`run-dsh.sh` の最後に session id を付ける。session id は実行のたびに「結果」の行に出る。

- 同じフォルダでしか続けられない。別のフォルダ、ない id は、終了コード 1 で止まる。ワークツリーを消すと続けられない。
- 打ち切りのあとも同じ id で続けられる。ワークツリーの変更はそのまま残る。

## 権限（確かめた範囲）

既定は workspace-write。`run-dsh.sh` は workspace-write と read-only だけを通し、`danger-full-access` を拒否する。`settings.json` の deny でも止めている。

| 操作 | workspace-write | read-only |
|---|---|---|
| ワークツリーの中に書く | できる | できない |
| ワークツリーの外（ホームなど）に書く | できない | できない |
| 一時フォルダ（`/tmp`、`$TMPDIR`）に書く | できる | 未確認 |
| `git commit`（共有の `.git` への書き込み） | できない | できない |
| ファイルを読む（ホームも含む） | できる | できる |
| ネットワーク | できる | 未確認 |
| `gh` の既定の認証 | `run-dsh.sh` が隠す | `run-dsh.sh` が隠す |

- ワーカーが `sandbox_permissions` で権限の昇格を求めても、headless には承認の窓口がないので失敗する（確かめた）。
- サンドボックスが止めるのはファイルの書き込みだけ。**読み取りとネットワークは止まらない。** ワーカーは `~/.ssh` やアプリの認証ファイルを読めるし、外に送れる。信頼できない人が書いた Issue やコードは、中身を確かめてから渡す。公式の文書も、ネットワークとプロセスの可視性は保証の外としている。
- `run-dsh.sh` は、空の `GH_CONFIG_DIR` を渡し、`GH_TOKEN`・`GITHUB_TOKEN`・`SSH_AUTH_SOCK` を外す。そのままでは `gh` は未ログインになる（確かめた）。**これは誤操作を防ぐもので、境界ではない。** ワーカーは環境変数を戻せるし、keyring や SSH の鍵は読めるので、その気になれば push やマージができる。GitHub の操作は指揮者がする決まりにし、依頼文でも禁じているが、強制はできない。
- ワーカーが動かすコマンドの標準の出力先がホームのキャッシュだと、書き込みが拒否されて失敗する。ゲームエンジンなどは、キャッシュや設定の場所を環境変数でワークツリーか一時フォルダに向ける。向けられないものは指揮者が動かす。

## データ

- 依頼文、読んだファイル、コマンドの出力は `api.deepseek.com` に送られる。Open Platform のプライバシーポリシーでは、データは中国のサーバーに保存され、入力はアカウントがある間は保持される。学習に使わないよう求める窓口はあるが、Harness のアカウント経由の入力に当てはまるかは未確認。非公開のリポジトリに使う前に、操作者が [Harness の利用規約](https://www.deepseek.com/en/harness/terms-of-use/) と [プライバシーポリシー](https://cdn.deepseek.com/policies/en-US/deepseek-privacy-policy.html) を確かめ、判断を段階表か上書き設定に書く。
- `run-dsh.sh` は `DSH_TELEMETRY_DISABLED=1` を付ける。既定でも、テレメトリーは明示のフィードバックのあとにしか送られない。
- セッションは `~/.dsh/sessions/` に残る。

## 打ち切り

`run-dsh.sh` の秒数で止まり、終了コードは 124 になる。macOS では `with_timeout` がプロセスグループに TERM を送り、5 秒後に KILL するので、ワーカーが起動したコマンドも残らない（確かめた）。

## 読むだけのレビューをさせる（Codex の枠が尽きたときの予備）

```bash
DSH_PERMISSION_MODE=read-only bash ~/.claude/skills/agent-orchestrate/scripts/run-dsh.sh 600 <PR のワークツリー> <モデル> <依頼文ファイル>
```

- read-only のサンドボックスが書き込みを止める。依頼文には、手順 4 の指定（編集・commit はしない、正しさのバグだけ、重大度・ファイル:行・起きる手順で）と、差分の見方（`git diff origin/<base>...HEAD`）を書く。`gh` は使えない。
- PR のブランチがチェックアウトされたワークツリーで動かす。ワーカーがまだ動いているワークツリーでは動かさない。
- 指摘は Codex のレビューと同じく、そのまま信じず、該当箇所を自分で読んで本当か確かめてから直させる。

## Windows（未確認）

Mac でしか動かしていない。公式の文書によると、次の点が macOS と違う。

- ワーカーのシェルの道具は bash ではなく PowerShell になる。
- サンドボックスは ACL で実現され、`partial` の扱いになる（強制しきれない範囲がある）。
- アプリが `dsh` を PATH に入れる手順が別にある（`runtime/cli/command-path.ps1`）。見つからないときは `DSH_BIN` で指定する。
- Git Bash では `timeout` が効かないことがある。かかりすぎたら、プロセスを止める。
