. "$HOME/.local/bin/env"
eval $(uv generate-shell-completion zsh)

export LANG=en_US.UTF-8
export EDITOR="nvim"

# Go
# Check if Go binary path is already in $PATH
if [[ ":$PATH:" != *":/usr/local/go/bin:"* ]]; then
    export PATH=$PATH:/usr/local/go/bin
fi

# Zig
# if [[ ":$PATH:" != *":/usr/local/zig:"* ]]; then
#     export PATH=$PATH:/usr/local/zig
# fi

# Add stuff in local/bin to path, mainly fd
export PATH=$HOME/.local/bin/:$PATH

# Rust
source "$HOME/.cargo/env"

# pnpm
export PNPM_HOME="/home/jesper/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
