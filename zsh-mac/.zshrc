# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

zstyle ':omz:update' mode reminder
zstyle ':omz:update' frequency 14

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

plugins=(
  git
  # zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


# Git commands
alias gs="git status"
# function lazygit_cmd() {
#     if [ -z "$1" ]; then
#         echo "Please provide a commit message."
#         return 1
#     fi
#
#     git add .
#     git commit -m "$1"
#     git push
# }
# alias lazygit="lazygit_cmd"
alias sn='git add . && git commit -m "sc" && git push'

alias lg='XDG_CONFIG_HOME="$HOME/.config" lazygit'

# Notes alias
alias notes="cd ~/Documents/Obsidian/obsidian-notes/JespersVault/ && git fetch"
alias v="nvim"
alias vf="nvim ."
alias cdd="cd ~/Desktop" 

alias tl="tree -L 2"
alias tla="tree -aL 2"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Python
alias py="python3"
alias pip="pip3"

# fzf
# Does this really need to be at the end of the file?
eval "$(fzf --zsh)"
bindkey "^F" fzf-cd-widget
bindkey -r "^[c"

# Coloured cat (ccat)
alias c="ccat"

# Avoid typing the wrong command...
alias vim="nvim"

alias onew="notes && nvim -c \"lua require('lazy').load({ plugins = { 'obsidian.nvim' } })\" -c 'Obsidian new'"

alias conda-init="source /opt/homebrew/Caskroom/miniforge/base/etc/profile.d/conda.sh && conda activate base"
