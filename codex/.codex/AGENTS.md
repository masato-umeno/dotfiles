# Global Working Preferences

- Use the user's language for conversation and the project's language and style for repository content.
- Lead with outcomes and blockers. Keep progress and failure excerpts concise, and state assumptions that materially affect behavior, data, security, cost, or scope.
- Never read or expose `.env` files, credentials, private keys, or credential-bearing URLs unless the user explicitly identifies the exact file and requests it. Prefer documented examples and non-secret placeholders.
- Preserve unrelated changes. Resolve destructive targets first and prefer reversible actions.
- For non-trivial work, give a short outcome-oriented plan, make the smallest coherent change, and verify it through documented project entry points in proportion to risk.
- Continue through actionable failures while each attempt adds evidence. Stop when failures repeat unchanged or progress requires credentials, a consequential user choice, or broader authority.
- Do not commit, push, open or merge a pull request, publish a release, or change repository settings unless the user requests that workflow. Never merge or release without explicit authorization.

## Long-running work and computer use

- Treat commands expected to run for about 10 minutes or longer as long-running work. This includes builds, tests, monitoring, network operations, and other tasks that could be interrupted by system sleep.
- For a long-running CLI command, bind the sleep-prevention assertions to the command so they are released when it exits:

  ```sh
  caffeinate -dis <command>
  ```

- For multiple shell operations, wrap the complete sequence in a shell command so the assertions cover the whole sequence and are released when it finishes:

  ```sh
  caffeinate -dis sh -c '<commands>'
  ```

- When using computer use for browser or GUI work that is expected to take about 10 minutes or longer, or that includes uploads, downloads, external-service waits, monitoring, generation, or export operations, start a timed assertion before the interaction begins:

  ```sh
  caffeinate -dis -t <timeout-seconds> >/dev/null 2>&1 &
  ```

- Choose a timeout with enough margin for the expected interaction. Let the timed assertion expire naturally after the work, and renew it if the work continues. Do not use it for short searches, a few clicks, or other interactions that finish promptly.
- Do not start `caffeinate` without a command or timeout for unattended work, because it would require manual cleanup. The `-u` option is for a brief user-activity assertion and is not a substitute for continuous sleep prevention; use `-dis` for these workflows.

## Repository workflow with GHQ

- Use GHQ for repository acquisition, discovery, and location: prefer `ghq get`, `ghq list`, `ghq list -p`, and `ghq root`.
- Use Git for version-control operations such as `status`, `diff`, branch management, commits, and history inspection. GHQ is not a full replacement for Git.
