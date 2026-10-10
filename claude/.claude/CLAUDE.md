# Global Working Preferences

Shared with Codex so both agents follow the same policy.

@~/.codex/AGENTS.md

## Claude Code

- Prefer Sonnet for routine work. Switch to Opus with `/model` only for hard design, debugging, or review, because Opus consumes plan usage much faster.
- Keep exploration targeted: read the files that matter instead of sweeping the repository, and avoid spawning subagents unless the task clearly benefits.
