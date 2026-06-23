# Repository Guidelines

## Project Structure & Module Organization

This repository is a dotfiles source of truth managed with GNU Stow. Put files under a top-level Stow package directory, mirroring their target paths below `$HOME`. Keep shared automation under `scripts/`, and platform-specific notes or configs under `windows/`.

## Build, Test, and Development Commands

- `stow --simulate --target="$HOME" codex ghq git nix vim vscode zed zsh` — preview the default macOS links.
- `stow --target="$HOME" codex ghq git nix vim vscode zed zsh` — apply the default macOS links.

There is no build system. Validate changes with a Stow simulation and then reload the target app (e.g., reopen Zed or start a new shell) to confirm expected behavior.

## Coding Style & Naming Conventions

- Keep edits minimal and consistent with existing file styles.
- Lua configs generally use two-space indentation and trailing commas in tables where present.
- Prefer lowercase filenames and conventional dot-config paths (e.g., `app/.config/app/...`).

## Testing Guidelines

There are no automated tests in this repository. Use the documented Stow simulation as the primary structural check, then perform a lightweight manual check relevant to the change and keep commits scoped to a single, verifiable change.

## Notes

Global agent policies live under `codex/.codex/AGENTS.md`. Keep this file focused on repository-specific guidance.
