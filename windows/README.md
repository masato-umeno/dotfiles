# Windows のセットアップ

Windows のセットアップは **winget を既定のパッケージマネージャー**として使う。Scoop は Git Bash から
使うと便利な開発者向け CLI ツールのためだけに残している。Chocolatey は不要。

前提: `winget`(アプリ インストーラー)が使えること。

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
cd $HOME\dotfiles
.\windows\bootstrap.ps1
```

bootstrap は Git for Windows を含む通常の Windows アプリを winget でインストールし、次の CLI ツールを
Scoop でインストールする:

- `direnv`
- `fzf`
- `ghq`
- `jq`
- `zoxide`

A5:SQL Mk-2 は winget 経由で Microsoft Store からインストールする。Microsoft Store へのサインインが
必要な場合がある。

Git Bash の設定は `windows/git-bash/` から `~/.bashrc` と `~/.bash_profile` にコピーされる。これらの
ファイルはこのリポジトリで管理しており、bootstrap を再実行すると上書きされる。

Git Bash の設定は意図的に軽量にしている。シェルフレームワークを追加せずに、zsh 環境と共通の
エイリアスとリポジトリ用ヘルパー、zoxide/direnv の連携、Ctrl-R での fzf 履歴検索、Docker Compose の
エイリアス、`ai-commit` ヘルパーを提供する。

bootstrap の実行後は PowerShell と Git Bash を開き直す。

## Node / Python(mise + uv)

ランタイムのバージョンは mise、Python のパッケージと venv は uv で管理する。どちらも winget で入る。

- グローバル設定は `windows/mise/config.toml` から `~/.config/mise/config.toml` にコピーされる
  (Node は LTS、Python は 3.13)。macOS 用の `mise/` パッケージとは別に持つ。
- `%LOCALAPPDATA%\mise\shims` を User PATH の先頭に追加する。シェルの activate ではなく shims を使うので、
  VS Code や Unity などシェルを経由しないアプリからも同じ node / python が見える。
- プロジェクトごとのバージョンは `mise use node@22` などで `mise.toml` に書く。
- Python のプロジェクトでは `uv init` / `uv add` / `uv run`、CLI ツールは `uv tool install` を使う。
  uv は mise が入れた Python を見つけて使う。
- 更新は `winget upgrade jdx.mise` / `winget upgrade astral-sh.uv`(`mise self-update` は使わない)。

手動で片付けるもの:

- nvm-windows / pyenv-win が入っていればアンインストールし、User PATH と `NVM_HOME` / `NVM_SYMLINK` を消す。
- 「設定 → アプリ → アプリ実行エイリアス」で `python.exe` / `python3.exe` をオフにする(任意)。
