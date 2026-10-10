# dotfiles

dotfiles の正本。編集はこのリポジトリのチェックアウトでのみ行う。既存のチェックアウトは
`ghq list -p` で探す。

ユーザー設定は GNU Stow で、グローバルなコマンドラインツールと macOS アプリはルートの
`Brewfile` で管理する。Nix は各プロジェクトのリポジトリで定義する開発環境専用とする。

## Stow で適用する

前提: GNU Stow。このリポジトリのチェックアウトのルートで実行する。

```shell
packages=(claude codex ghostty ghq git nix vim vscode zed zsh)
stow --simulate --target="$HOME" "${packages[@]}"
stow --target="$HOME" "${packages[@]}"
```

パッケージの中身を変えたあとは `--restow` を、パッケージのリンクを外すときは `--delete` を使う:

```shell
stow --restow --target="$HOME" zsh
stow --delete --target="$HOME" zsh
```

Stow は既存ファイルを置き換えず、競合があると停止する。移行中は、対応するパッケージを適用する前に
Home Manager が作ったリンクやファイルを削除するかバックアップする。`--adopt` はリポジトリの内容を
上書きすることがあるため、変更を確認せずに使わない。

## 個人用の Git 設定

共有の Git 設定は、識別情報とマシン固有の上書き設定のために `~/.config/git/config.local` を読み込む。
このファイルはローカルマシン上の、このリポジトリと Stow パッケージの外に置く。使うコミット用の識別情報は
そこで設定する:

```shell
git config --file "$HOME/.config/git/config.local" user.name "YOUR_COMMIT_NAME"
git config --file "$HOME/.config/git/config.local" user.email "YOUR_COMMIT_EMAIL"
```

コミットの名前とメールアドレスは公開されてよいものを選ぶ。設定をローカルに置いても、Git のコミットに
記録される作者情報は隠れない。現在のファイルから個人情報を消しても、既存の Git 履歴や GitHub
アカウントのメタデータからは消えない。

## Homebrew

`Brewfile` で宣言したものをすべてインストールする:

```shell
brew bundle install --file=Brewfile
```

MacTeX をインストールしたら、TeX Live のパッケージマネージャーとインストール済みパッケージを更新する:

```shell
sudo tlmgr update --self && sudo tlmgr update --all
```

マシンの状態が宣言と一致しているか確認する:

```shell
brew bundle check --file=Brewfile
```

削除する前に、インストール済みだが宣言されていないパッケージを確認する:

```shell
brew bundle cleanup --file=Brewfile
```

## 構成

各トップレベルのパッケージは `$HOME` 以下のパスをそのまま再現する:

- `zsh/.zshrc` は `~/.zshrc` になる。
- `git/.config/git/config` は `~/.config/git/config` になる。
- `claude/.claude/` は Claude Code のグローバルな指示、設定、スキルを提供する。
- `codex/.codex/` は Codex のグローバルな指示を提供する。実行時ファイル、キャッシュ、
  秘密情報、学習された状態は管理しない。
- `vscode/Library/Application Support/Code/User/settings.json` は macOS の VS Code
  設定パスに配置される。
- `windows/` には Windows 用の別セットアップがある。

## プロジェクトごとの Nix

`flake.nix`、`flake.lock`、開発用の依存関係は、必要な各プロジェクトに置く。プロジェクトの環境には
`nix develop` で入るか、`use flake` を呼ぶ `.envrc` を用意して `direnv` を使う。

## ghq

```shell
ghq get https://github.com/OWNER/REPO
ghq list
```

このリポジトリは `ghq` の設定も管理する。ルートは `~/ghq` なので、GitHub のリポジトリは
`~/ghq/github.com/OWNER/REPO` に置かれる。

`ghq get` でクローンし、`$(ghq root)` 以下のリポジトリに移動する。

## Codex

`codex` Stow パッケージはグローバルな指示を `~/.codex/` にリンクする。実行時ファイル、キャッシュ、
秘密情報、マシンローカルな Codex の状態は管理しない。

### 権限と管理対象ファイル

別のサンドボックスラッパーではなく、Codex 標準の権限モードを使う。ワークスペースの範囲から始め、
作業に必要なときだけタスクごとに広い権限を選ぶ。現在のモードの確認や変更には `/permissions` を使う。

グローバルな指示は `~/.codex/AGENTS.md` にある。学習されたコマンドルール、アプリ設定、認証、
プラグイン、キャッシュ、ログ、セッションなどの実行時の状態はマシンローカルに置く。

### モデルと使用量

ChatGPT Plus プランでは、マシンローカルの `~/.codex/config.toml` で既定を `gpt-6-sol`、
reasoning を `medium`、plan モードを `high` にする。軽い作業は `gpt-6-luna`、難しい作業は
`gpt-6-astra` に `/model` で切り替える。

## Claude Code

`claude` Stow パッケージは `~/.claude/CLAUDE.md`、`~/.claude/settings.json`、
`~/.claude/skills/` をリンクする。`CLAUDE.md` は `~/.codex/AGENTS.md` を読み込むので、
`codex` パッケージも適用し、共通の方針はそちらに書く。`codex` スキルにより、Claude Code は
価値があると判断したときに Codex CLI を読み取り専用で呼び、独立したレビューやセカンドオピニオンを得られる。

`settings.json` は Pro プランでの開発向けに既定を Opus 5.5 の medium effort にし、よくある秘密情報の
場所の読み取りを拒否する。Claude Code の使用量が尽きたら Codex で続ける。ファイルはリンクされているため、
Claude Code がユーザー設定に保存した変更はこのリポジトリに反映される。コミット前に確認する。
認証情報、セッション、キャッシュなどの実行時の状態は管理しない。

Windows については `windows/README.md` を参照。
