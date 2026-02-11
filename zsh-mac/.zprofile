eval $(/opt/homebrew/bin/brew shellenv)
eval $(uv generate-shell-completion zsh)

# Paths
# IntelliJ Maven
if [[ ":$PATH:" != *":/Applications/IntelliJ IDEA.app/Contents/plugins/maven/lib/maven3/bin:"* ]]; then
    export PATH="/Applications/IntelliJ IDEA.app/Contents/plugins/maven/lib/maven3/bin:$PATH"
fi



export LANG=en_US.UTF-8
export EDITOR="nvim"

export FZF_DEFAULT_COMMAND='fd --type file'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:#d0d0d0,fg+:#d0d0d0,bg:-1,bg+:#484848
  --color=hl:#5f87af,hl+:#5fd7ff,info:#afaf87,marker:#87ff00
  --color=prompt:#d7005f,spinner:#af5fff,pointer:#af5fff,header:#87afaf
  --color=border:#262626,label:#aeaeae,query:#d9d9d9
  --border="rounded" --border-label="" --preview-window="border-rounded" --prompt="> "
  --marker=">" --pointer="◆" --separator="─" --scrollbar="│"'
