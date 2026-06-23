# dotfiles

Source of truth for my dotfiles. Edit only in this repository checkout,
typically under `$(ghq root)/github.com/01-mu/dotfiles`.

GNU Stow manages user configuration, and the root `Brewfile` manages global
command-line tools and macOS applications. Nix is reserved for development
environments defined by each project repository.

## Apply with Stow

Prerequisite: GNU Stow.

```shell
cd "$(ghq root)/github.com/01-mu/dotfiles"
packages=(codex ghostty ghq git nix vim vscode zed zsh)
stow --simulate --target="$HOME" "${packages[@]}"
stow --target="$HOME" "${packages[@]}"
```

Use `--restow` after changing package contents and `--delete` to remove a
package's links:

```shell
stow --restow --target="$HOME" zsh
stow --delete --target="$HOME" zsh
```

Stow stops on conflicts instead of replacing existing files. During the
migration, remove or back up links and files previously created by Home
Manager before applying the corresponding package. Do not use `--adopt`
without reviewing its changes because it can overwrite repository content.

## Homebrew

Install everything declared in `Brewfile`:

```shell
brew bundle install --file=Brewfile
```

Check whether the machine matches the declarations:

```shell
brew bundle check --file=Brewfile
```

Preview packages that are installed but not declared before removing any:

```shell
brew bundle cleanup --file=Brewfile
```

## Layout

Each top-level package mirrors its paths below `$HOME`:

- `zsh/.zshrc` becomes `~/.zshrc`.
- `git/.config/git/config` becomes `~/.config/git/config`.
- `codex/.codex/` contributes only repository-managed Codex files; runtime
  files, caches, and secrets remain unmanaged in `~/.codex/`.
- `vscode/Library/Application Support/Code/User/settings.json` targets the
  macOS VS Code settings path.
- `windows/` contains the separate Windows setup.

## Per-project Nix

Put `flake.nix`, `flake.lock`, and development dependencies in each project
that needs them. Enter a project environment with `nix develop`, or use
`direnv` with an `.envrc` that calls `use flake`.

## ghq

```shell
ghq get https://github.com/OWNER/REPO
ghq list
```

This repo manages the `ghq` config too. The root is `~/ghq`, so GitHub repositories are stored under `~/ghq/github.com/OWNER/REPO`.

Clone with `ghq get`, then move to a repo under `$(ghq root)`.

## Codex

The `codex` Stow package links repository-managed files into `~/.codex/`.
Runtime files, caches, secrets, and machine-local Codex state stay only under
`~/.codex/`.

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

Windows: see `windows/README.md`.
