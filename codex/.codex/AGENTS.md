# Agent Advisory (soft policy)

- Never read `.env` or other secrets files.
- Never print secrets to the terminal or logs.
- Prefer `.env.example` or documented config samples.
- If configuration is needed, ask the user for non-secret placeholders.

## Language Policy

- All interactive communication with the user MUST be in English unless explicitly instructed otherwise.
- For natural-language content produced for a project (commit messages, comments, docs, Markdown),
  follow the project's language rules when they exist; otherwise default to English.
- Do not switch languages in user-facing communication unless explicitly instructed.
- If project-specific rules define commit message conventions, follow those rules even if they differ.
- When editing Markdown, review surrounding context and make additions feel consistent and non-jarring.

This rule applies across all tasks unless overridden by a higher-priority system instruction.

## Verification and Reporting Policy
- Apply this flow only for coding or behavioral changes; documentation-only edits do not require test execution.
- Always follow: plan (max 3 bullets) -> implement minimal change -> run the primary test -> report and stop.
- Use only a defined test entry point from README/Makefile/package metadata; if none exists, report "unable to run tests" and stop.
- Limit test runs to 2 total: run once; if it fails, apply a minimal fix and rerun once; if it fails again, stop and report with up to 3 hypotheses and one next step.
- Do not run extra checks (lint/type/e2e/bench) unless explicitly requested; at most one additional check.
- Do not paste full logs; include only key lines (<= 15).
- Avoid cost blowups: no brute-force retries, no mass installs or upgrades; when blocked, ask for the minimum needed info and stop.
- When updating Codex policies, provide patches against this repository’s `codex/.codex/` content for the user to apply.

## Release and PR policy
- For released products, never merge directly to `main`; merge progress into `dev`.
- Only open `dev` -> `main` PRs when the user explicitly instructs it.
- PR approval happens in the user's GitHub browser; do not assume approval.
- Keep PR messages formatting-safe; avoid line breaks or formatting that can collapse in GitHub UI.
