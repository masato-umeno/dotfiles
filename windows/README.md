# Windows setup

Windows setup uses **winget as the default package manager**. Scoop is kept only
for developer CLI tools that are convenient to use from Git Bash. Chocolatey is
not required.

Prerequisite: `winget` (App Installer) must be available.

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
cd $HOME\dotfiles
.\windows\bootstrap.ps1
```

The bootstrap installs regular Windows applications with winget, including Git
for Windows, and installs these CLI tools with Scoop:

- `direnv`
- `fzf`
- `ghq`
- `jq`
- `zoxide`

A5:SQL Mk-2 is installed from Microsoft Store through winget. Microsoft Store
sign-in may be required.

Git Bash settings are copied from `windows/git-bash/` to `~/.bashrc` and
`~/.bash_profile`. Those files are managed by this repository and are
overwritten when the bootstrap is run again.

The Git Bash configuration intentionally stays lightweight. It provides the
common aliases and repository helpers from the zsh setup, zoxide/direnv
integration, fzf history search on Ctrl-R, Docker Compose aliases, and the
`ai-commit` helper without adding a shell framework.

Reopen PowerShell and Git Bash after running the bootstrap.
