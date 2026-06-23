# dotfiles

Source of truth for my dotfiles. Edit only in this repository checkout, typically under `$(ghq root)/github.com/01-mu/dotfiles`.
macOS is managed with `nix-darwin` plus `home-manager`.
Prereq: Nix with flakes enabled.

## Apply on macOS

```shell
cd "$(ghq root)/github.com/01-mu/dotfiles"
```

First switch:

```shell
sudo nix run github:LnL7/nix-darwin -- switch --flake .#01-mu
```

Later switches:

```shell
darwin-rebuild switch --flake .#01-mu
```

`home-manager` is wired through the Darwin configuration, so one switch applies both system settings and user dotfiles.
Package ownership is split by responsibility:

- [`nix/modules/home/packages.nix`](nix/modules/home/packages.nix): minimal global CLI tools.
- [`nix/modules/darwin/homebrew.nix`](nix/modules/darwin/homebrew.nix): GUI apps and host-specific exceptions.
- Project repositories: runtimes and build dependencies via `devShell`s.

## Layout

- `home/` mirrors files that land in `$HOME`, such as `.zshrc`, `.vimrc`, `.config/...`, VS Code metadata, and Codex settings.
- `nix/` contains the Nix modules used by `flake.nix`.
- `windows/` keeps Windows-specific setup files.

## ghq

```shell
ghq get https://github.com/OWNER/REPO
ghq list
```

This repo manages the `ghq` config too. The root is `~/ghq`, so GitHub repositories are stored under `~/ghq/github.com/OWNER/REPO`.

Clone with `ghq get`, then move to a repo under `$(ghq root)`.

## Codex

Home Manager syncs repository-managed files from `home/.codex/` into `~/.codex/`.
Runtime files, caches, secrets, and machine-local Codex state stay only under `~/.codex/`.

### Safe wrapper

```shell
export PATH="$HOME/.codex/bin:$PATH"
```

```shell
codex-safe
```

Optional checks:

```shell
codex execpolicy check --pretty --rules ~/.codex/rules/policy-deny.rules -- sudo ls
sandbox-exec -f ~/.codex/sandbox/deny-secrets.sb cat .env
```

### Android / Termux

Android is not managed by `nix-darwin`, so sync the repository-managed Codex
files directly:

```shell
pkg install git rsync
git clone https://github.com/01-mu/dotfiles.git ~/dotfiles
cd ~/dotfiles
scripts/sync-codex
export PATH="$HOME/.codex/bin:$PATH"
codex-safe
```

To expand a disposable test session first:

```shell
scripts/codex-test-session
```

Windows: see `windows/README.md`.
