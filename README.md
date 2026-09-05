# dotfiles

Source of truth for my dotfiles. Edit only in this repository checkout. Use
`ghq list -p` to locate the existing checkout.

GNU Stow manages user configuration, and the root `Brewfile` manages global
command-line tools and macOS applications. Nix is reserved for development
environments defined by each project repository.

## Apply with Stow

Prerequisite: GNU Stow. Run from the root of this repository checkout.

```shell
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

## Personal Git settings

The shared Git configuration includes `~/.config/git/config.local` for
identity and machine-specific overrides. Keep that file on the local machine,
outside this repository and outside any Stow package. Configure your chosen
commit identity there:

```shell
git config --file "$HOME/.config/git/config.local" user.name "YOUR_COMMIT_NAME"
git config --file "$HOME/.config/git/config.local" user.email "YOUR_COMMIT_EMAIL"
```

Choose the commit name and email you want published. Keeping the settings
local does not hide the author identity recorded in Git commits. Removing
personal values from current files also does not remove them from existing
Git history or GitHub account metadata.

## Homebrew

Install everything declared in `Brewfile`:

```shell
brew bundle install --file=Brewfile
```

Update the TeX Live package manager and installed packages after installing
MacTeX:

```shell
sudo tlmgr update --self && sudo tlmgr update --all
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
- `codex/.codex/` contributes global Codex guidance, while
  `codex/.agents/skills/` contributes personal skills. Runtime files, caches,
  secrets, and learned state remain unmanaged.
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

The `codex` Stow package links global guidance into `~/.codex/` and personal
skills into `~/.agents/skills/`. Runtime files, caches, secrets, and
machine-local Codex state stay unmanaged.

### Permissions and managed files

Use Codex's native permission modes instead of a separate sandbox wrapper.
Start with the workspace boundary and choose broader permissions per task only
when the work requires them. Use `/permissions` to inspect or change the active
mode.

Global instructions live in `~/.codex/AGENTS.md`. Personal reusable skills live
in `~/.agents/skills/`. Learned command rules, app settings, authentication,
plugins, caches, logs, sessions, and other runtime state remain machine-local.

Windows: see `windows/README.md`.
