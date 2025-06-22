# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

zstyle ':omz:update' mode reminder  # just remind me to update when it's time
zstyle ':omz:update' frequency 13

plugins=(
    git
    # zsh-autosuggestions
    zsh-syntax-highlighting # Has to be installed manually in omz folder
)

source $ZSH/oh-my-zsh.sh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Help command
function help() {
	bash -c "help $@"
}

# Git
alias gs="git status"

# Python
alias py="python3"

alias lg="lazygit"

alias vim="nvim"
alias v="nvim"
alias vf="nvim ."

alias tl="tree -L 2"
alias tla="tree -aL 2"

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

# Java
# alias javac="javac.exe"
# alias java="java.exe"

# On launch commands
# clear

# fzf zsh keybindings
source <(fzf --zsh)

bindkey "^F" fzf-cd-widget
bindkey -r "^[c"

# Make the Ctrl + f faster with fdfind instead of find
export FZF_DEFAULT_COMMAND='fdfind --type file'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_ALT_C_COMMAND='fdfind --type d --hidden --exclude .git'

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:#d0d0d0,fg+:#d0d0d0,bg:-1,bg+:#484848
  --color=hl:#5f87af,hl+:#5fd7ff,info:#afaf87,marker:#87ff00
  --color=prompt:#d7005f,spinner:#af5fff,pointer:#af5fff,header:#87afaf
  --color=border:#262626,label:#aeaeae,query:#d9d9d9
  --border="rounded" --border-label="" --preview-window="border-rounded" --prompt="> "
  --marker=">" --pointer="◆" --separator="─" --scrollbar="│"'


# pnpm
export PNPM_HOME="/home/jesper/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
