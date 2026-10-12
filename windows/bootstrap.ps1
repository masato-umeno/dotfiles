Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$DesktopSource = Join-Path $RepoRoot "windows\desktop"
$DesktopTarget = [Environment]::GetFolderPath("Desktop")
$RunShortcutDir = "C:\runshortcut"
$ProfileSource = Join-Path $RepoRoot "windows\powershell\Microsoft.PowerShell_profile.ps1"
$ProfileTarget = Join-Path $HOME "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$GitBashRcSource = Join-Path $RepoRoot "windows\git-bash\.bashrc"
$GitBashRcTarget = Join-Path $HOME ".bashrc"
$GitBashProfileSource = Join-Path $RepoRoot "windows\git-bash\.bash_profile"
$GitBashProfileTarget = Join-Path $HOME ".bash_profile"
$GitBashInputRcSource = Join-Path $RepoRoot "windows\git-bash\.inputrc"
$GitBashInputRcTarget = Join-Path $HOME ".inputrc"
$WslConfigSource = Join-Path $RepoRoot "windows\wsl\.wslconfig"
$WslConfigTarget = Join-Path $HOME ".wslconfig"
$VscodeSource = Join-Path $RepoRoot "windows\vscode\settings.json"
$VscodeTarget = Join-Path $env:APPDATA "Code\User\settings.json"
$MiseConfigSource = Join-Path $RepoRoot "windows\mise\config.toml"
$MiseConfigTarget = Join-Path $HOME ".config\mise\config.toml"
$MiseShimsDir = Join-Path $env:LOCALAPPDATA "mise\shims"

$AppsWinget = @(
  "Git.Git",
  "jdx.mise",
  "astral-sh.uv",
  "WinMerge.WinMerge",
  "SlackTechnologies.Slack",
  "Zoom.Zoom",
  "Obsidian.Obsidian",
  "Google.Chrome",
  "SakuraEditor.SakuraEditor",
  "Microsoft.VisualStudioCode"
)

$AppsScoop = @(
  "direnv",
  "fzf",
  "ghq",
  "jq",
  "zoxide"
)

function Ensure-Directory([string]$Path) {
  if (-not (Test-Path $Path)) {
    New-Item -ItemType Directory -Path $Path | Out-Null
  }
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  throw "winget is required. Install or update App Installer, then run this script again."
}

Write-Host "[1/9] Install package managers"
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
  Invoke-RestMethod -Uri "https://get.scoop.sh" | Invoke-Expression
}

Write-Host "[2/9] Install apps and CLI tools"
foreach ($app in $AppsWinget) {
  winget install --id $app --exact --accept-source-agreements --accept-package-agreements
}
winget install --id "9NSBB9XTJW86" --exact --source msstore --accept-source-agreements --accept-package-agreements

foreach ($app in $AppsScoop) {
  scoop install $app
}

Write-Host "[3/9] Place .bat files on Desktop"
if (Test-Path $DesktopSource) {
  Ensure-Directory $DesktopTarget
  Copy-Item -Path (Join-Path $DesktopSource "*.bat") -Destination $DesktopTarget -Force
} else {
  Write-Host "skip: desktop source not found: $DesktopSource"
}

Write-Host "[4/9] Create C:\runshortcut and add to PATH"
Ensure-Directory $RunShortcutDir
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if (-not $UserPath) { $UserPath = "" }
if ($UserPath -notmatch [Regex]::Escape($RunShortcutDir)) {
  $NewUserPath = ($UserPath.TrimEnd(";") + ";" + $RunShortcutDir).TrimStart(";")
  [Environment]::SetEnvironmentVariable("Path", $NewUserPath, "User")
  $env:Path = $NewUserPath + ";" + $env:Path
}

Write-Host "[5/9] Install PowerShell profile"
if (Test-Path $ProfileSource) {
  Ensure-Directory (Split-Path $ProfileTarget -Parent)
  Copy-Item -Path $ProfileSource -Destination $ProfileTarget -Force
} else {
  Write-Host "skip: profile source not found: $ProfileSource"
}

Write-Host "[6/9] Install Git Bash settings"
if (
  (Test-Path $GitBashRcSource) -and
  (Test-Path $GitBashProfileSource) -and
  (Test-Path $GitBashInputRcSource)
) {
  Copy-Item -Path $GitBashRcSource -Destination $GitBashRcTarget -Force
  Copy-Item -Path $GitBashProfileSource -Destination $GitBashProfileTarget -Force
  Copy-Item -Path $GitBashInputRcSource -Destination $GitBashInputRcTarget -Force
} else {
  Write-Host "skip: Git Bash settings not found"
}

Write-Host "[7/9] Install .wslconfig"
if (Test-Path $WslConfigSource) {
  Copy-Item -Path $WslConfigSource -Destination $WslConfigTarget -Force
} else {
  Write-Host "skip: wsl config not found: $WslConfigSource"
}

Write-Host "[8/9] Install VS Code settings"
if (Test-Path $VscodeSource) {
  Ensure-Directory (Split-Path $VscodeTarget -Parent)
  Copy-Item -Path $VscodeSource -Destination $VscodeTarget -Force
} else {
  Write-Host "skip: vscode settings not found: $VscodeSource"
}

Write-Host "[9/9] Set up mise (Node / Python)"
if (Test-Path $MiseConfigSource) {
  Ensure-Directory (Split-Path $MiseConfigTarget -Parent)
  Copy-Item -Path $MiseConfigSource -Destination $MiseConfigTarget -Force
} else {
  Write-Host "skip: mise config not found: $MiseConfigSource"
}
# Prepend shims so they win over the Microsoft Store python stub in WindowsApps
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if (-not $UserPath) { $UserPath = "" }
if ($UserPath -notmatch [Regex]::Escape($MiseShimsDir)) {
  $NewUserPath = ($MiseShimsDir + ";" + $UserPath).TrimEnd(";")
  [Environment]::SetEnvironmentVariable("Path", $NewUserPath, "User")
}
$env:Path = [Environment]::GetEnvironmentVariable("Path", "User") + ";" + [Environment]::GetEnvironmentVariable("Path", "Machine")
mise install

Write-Host "Windows bootstrap complete."
Write-Host "Reopen PowerShell and Git Bash to load the updated environment."

Write-Host "Next steps (WSL2 + Ubuntu):"
Write-Host "  wsl --install -d Ubuntu"
Write-Host "  wsl --set-default-version 2"
Write-Host "  wsl --update"
Write-Host "Docker on Ubuntu:"
Write-Host "  sudo apt-get update"
Write-Host "  sudo apt-get install -y ca-certificates curl gnupg"
Write-Host "  sudo install -m 0755 -d /etc/apt/keyrings"
Write-Host "  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg"
Write-Host "  echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null"
Write-Host "  sudo apt-get update"
Write-Host "  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
Write-Host "  sudo usermod -aG docker $USER"
Write-Host "  newgrp docker"
