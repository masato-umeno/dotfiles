eval "$(/opt/homebrew/bin/brew shellenv)"

# 非対話シェル(エディタやエージェントのコマンド実行)でも mise のツールを使えるようにする
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh --shims)"
fi
