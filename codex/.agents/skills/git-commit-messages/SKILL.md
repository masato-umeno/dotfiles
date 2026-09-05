---
name: git-commit-messages
description: Write or review concise Git commit messages. Use when committing, proposing a commit message, splitting commits, or checking commit-message format; defer to repository-specific conventions when present.
---

# Git Commit Messages

Follow repository-specific conventions first. Otherwise:

- Use `type: summary` or `type(scope): summary`.
- Use one of: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `style`.
- Keep the summary lowercase, single-line, and free of emojis or `WIP`.
- Keep each commit small enough to describe clearly in one line.

Examples:

- `feat: add wezterm title bar controls`
- `fix(backend): handle nil config`
- `docs: update setup notes`
