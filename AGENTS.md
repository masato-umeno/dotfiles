# Repository Guidelines

## Project Structure & Module Organization

This repository is a dotfiles source of truth managed with GNU Stow. Put files under a top-level Stow package directory, mirroring their target paths below `$HOME`. Manage global macOS packages in the root `Brewfile`, and keep Windows-specific setup under `windows/`.

## Build, Test, and Development Commands

- `stow --simulate --target="$HOME" codex ghostty ghq git nix vim vscode zed zsh` — preview the default macOS links.
- `stow --target="$HOME" codex ghostty ghq git nix vim vscode zed zsh` — apply the default macOS links.
- `brew bundle check --file=Brewfile` — check whether Homebrew matches the declarations.

There is no build system. Validate changes with a Stow simulation and then reload the target app (e.g., reopen Zed or start a new shell) to confirm expected behavior.

## Coding Style & Naming Conventions

- Keep edits minimal and consistent with existing file styles.
- Prefer lowercase filenames and conventional dot-config paths (e.g., `app/.config/app/...`).

## Testing Guidelines

There are no automated tests in this repository. Use the documented Stow simulation as the primary structural check, then perform a lightweight manual check relevant to the change and keep commits scoped to a single, verifiable change.

## Notes

This repository is intended for public GitHub hosting. Use home-relative paths
and generic examples; keep personal identities and machine-specific values in
local files outside the repository and Stow packages. Git ignore rules do not
exclude files from Stow deployment.

Global agent policies live under `codex/.codex/AGENTS.md`. Keep this file focused on repository-specific guidance.
