eval "$(/opt/homebrew/bin/brew shellenv)"

# 非対話シェル(エディタやエージェントのコマンド実行)でも mise のツールを使えるようにする
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh --shims)"
fi

# DeepSeek Harness の cask は dsh を PATH に入れないので、アプリの中の CLI を足す
if [ -d "/Applications/DeepSeek Harness.app/Contents/Resources/runtime/cli/bin" ]; then
  path+=("/Applications/DeepSeek Harness.app/Contents/Resources/runtime/cli/bin")
fi
