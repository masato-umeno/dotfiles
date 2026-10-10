# リポジトリガイドライン

## プロジェクト構成とモジュール

このリポジトリは GNU Stow で管理する dotfiles の正本。ファイルはトップレベルの Stow パッケージディレクトリに置き、`$HOME` 以下の配置先パスをそのまま再現する。macOS のグローバルパッケージはルートの `Brewfile` で管理し、Windows 固有のセットアップは `windows/` に置く。

## ビルド、テスト、開発コマンド

- `stow --simulate --target="$HOME" claude codex ghostty ghq git nix vim vscode zed zsh` — macOS の既定リンクをプレビューする。
- `stow --target="$HOME" claude codex ghostty ghq git nix vim vscode zed zsh` — macOS の既定リンクを適用する。
- `brew bundle check --file=Brewfile` — Homebrew の状態が宣言と一致するか確認する。

ビルドシステムはない。変更は Stow のシミュレーションで検証し、対象アプリを再読み込みして(Zed を開き直す、新しいシェルを起動するなど)期待どおり動くか確認する。

## コーディングスタイルと命名規則

- 編集は最小限にし、既存ファイルのスタイルに合わせる。
- ファイル名は小文字にし、慣例的な dot-config パスを使う(例: `app/.config/app/...`)。

## テスト方針

自動テストはない。ドキュメント化された Stow シミュレーションを主な構造チェックとし、変更に応じた軽い手動確認を行う。コミットは単一の検証可能な変更にまとめる。

## 注意事項

このリポジトリは GitHub で公開する前提。パスはホーム相対にし、例は汎用的なものにする。個人の識別情報やマシン固有の値は、リポジトリと Stow パッケージの外にあるローカルファイルに置く。Git の ignore ルールは Stow の配置対象から除外しない。

グローバルなエージェント方針は `codex/.codex/AGENTS.md` にある。このファイルはリポジトリ固有のガイダンスに絞る。
