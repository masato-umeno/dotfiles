# Commands shared with the zsh and Git Bash settings. ls is PowerShell's alias of Get-ChildItem.
function ll { Get-ChildItem @args }
function la { Get-ChildItem -Force @args }
function grep {
  if ($MyInvocation.ExpectingInput) { $input | Select-String @args } else { Select-String @args }
}
function lg { Get-ChildItem -Force | Where-Object Name -Match $args[0] }
function .. { Set-Location .. }
function ... { Set-Location ..\.. }

Set-Alias j z
Set-Alias g git

# Prefer the CLI bundled with the Codex app; an older winget CLI fails sandbox setup.
$codexApp = Get-ChildItem "$env:LOCALAPPDATA\OpenAI\Codex\bin\*\codex.exe" -ErrorAction SilentlyContinue |
  Sort-Object LastWriteTime | Select-Object -Last 1
if ($codexApp) {
  $env:PATH = "$($codexApp.DirectoryName);$env:PATH"
}

if (Test-Path "$PWD\workspace") {
  Set-Location "$PWD\workspace"
}

# Search command history with fzf on Ctrl-R, newest first.
if ((Get-Command fzf -ErrorAction SilentlyContinue) -and (Get-Module PSReadLine)) {
  Set-PSReadLineKeyHandler -Chord Ctrl+r -ScriptBlock {
    $historyPath = (Get-PSReadLineOption).HistorySavePath
    if (-not (Test-Path $historyPath)) { return }

    $lines = @(Get-Content $historyPath)
    $seen = [System.Collections.Generic.HashSet[string]]::new()
    $entries = for ($i = $lines.Count - 1; $i -ge 0; $i--) {
      if ($seen.Add($lines[$i])) { $lines[$i] }
    }

    $selected = $entries | fzf +s
    if ($selected) {
      [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selected)
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
  }
}

if (Get-Command direnv -ErrorAction SilentlyContinue) {
  # direnv finds its config directory from HOME, which PowerShell does not set.
  if (-not $env:HOME) { $env:HOME = $HOME }
  Invoke-Expression (direnv hook pwsh | Out-String)
}

# For zoxide v0.8.0+
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
  Invoke-Expression (& {
      $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
      (zoxide init --hook $hook powershell | Out-String)
  })
}

# Choose a repository from ghq and return its full path.
function repo_path {
  $dir = ghq list | fzf
  if (-not $dir) { return }
  Join-Path (ghq root) $dir
}

function repo {
  $selectedRepoPath = repo_path
  if ($selectedRepoPath) { Set-Location $selectedRepoPath }
}

function repo-code {
  $selectedRepoPath = repo_path
  if ($selectedRepoPath) { code -r $selectedRepoPath }
}

Set-Alias rc repo-code

# Generate commit messages from the staged diff and split it into logical commits.
function ai-commit {
  if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
    Write-Error "codex: command not found"
    return
  }

  git diff --cached --quiet
  if ($LASTEXITCODE -eq 0) {
    Write-Host "No staged changes."
    return
  }
  if ($LASTEXITCODE -ne 1) { return }

  $diff = git diff --cached | Out-String

  $plan = @"
Analyze the following git diff and split it into logical commits.

Return JSON:
[
  {
    "message": "...",
    "files": ["..."]
  }
]

Rules:
- Use Conventional Commits
- Group by logical concern
- Avoid mixing unrelated changes

Diff:
$diff
"@ | codex exec | Out-String

  Write-Host "---- Proposed commit plan ----"
  Write-Host $plan
  Write-Host "------------------------------"

  $confirm = Read-Host "Proceed with this plan? (y/N)"
  if ($confirm -ne "y") { return }

  foreach ($entry in ($plan | ConvertFrom-Json)) {
    git reset
    git add -- @($entry.files)

    Write-Host "Committing: $($entry.message)"
    $entry.message | git commit -F -
  }
}

# docker
function dc { docker compose @args }
function dcb { docker compose build @args }
function dcr { docker compose restart @args }
function dcu { docker compose up -d @args }
function dce { docker compose exec @args }
function dcd { docker compose down @args }
