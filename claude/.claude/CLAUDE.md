# Global Working Preferences

Shared with Codex so both agents follow the same policy.

@~/.codex/AGENTS.md

## Claude Code

- Default to Opus 5.5 at medium effort. Raise effort with `/effort` only for hard design, debugging, or review, and use Sonnet for mechanical bulk edits to conserve plan usage.
- Keep exploration targeted: read the files that matter instead of sweeping the repository, and avoid spawning subagents unless the task clearly benefits.
