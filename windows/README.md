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
