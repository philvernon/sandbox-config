# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --------------------------------------------------
# OPTIONS
# --------------------------------------------------

export EDITOR="nvim"
export GOPATH="$HOME/go"

if [[ "$OSTYPE" == darwin* ]]; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
fi

export FZF_DEFAULT_COMMAND="fd --type f"
export FZF_DEFAULT_OPTS='--color=bg+:-1'

# --------------------------------------------------
# PATHS
# --------------------------------------------------

typeset -U path PATH

path=(
  "$HOME/.cargo/bin"
  "$HOME/.local/bin"
  "$GOPATH/bin"
  "$HOME/bin"
  $path
)
export PATH

eval "$(zoxide init zsh)"

# --------------------------------------------------
# Plugins
# --------------------------------------------------

plugins_file="$HOME/.zsh_plugins"

if [[ ! "${plugins_file}.zsh" -nt "${plugins_file}.txt" ]]; then
  (
    source "$HOME/.local/share/antidote/antidote.zsh"
    antidote bundle < "${plugins_file}.txt" > "${plugins_file}.zsh"
  )
fi

source "${plugins_file}.zsh"

# --------------------------------------------------
# Completion
# --------------------------------------------------

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' prefix ''

# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'

zstyle ':fzf-tab:*' show-group none
zstyle ':fzf-tab:*' fzf-pad 0
zstyle ':fzf-tab:*' fzf-min-height 0
zstyle ':fzf-tab:*' popup-min-size 0 0
zstyle ':fzf-tab:complete:cd:*' popup-pad 4 4
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' use-fzf-default-opts yes

# --------------------------------------------------
# Aliases
# --------------------------------------------------

alias c="clear"
alias tree="tree -I node_modules"
alias ev="exit"
alias nrd="npm run dev"
alias pbc='pwd | tmux load-buffer -w -'
alias tmus="tmux"
# FOR NVIM CONFIG REWRITE
alias vimn="NVIM_APPNAME=neovim-rewrite nvim"
alias pe="cd ~/.pi"

# Go to config
alias vc="cd ~/.config"
alias vcn="cd $HOME/.config/nvim"
alias cz="nvim $HOME/.zshrc"

# nvim
alias vim="nvim"
alias v="nvim"
alias vb="nvim '+SessionRestore'"
alias n="nvim"
alias ,="nvim ."

# apps
alias r="ranger"



# --------------------------------------------------
# Custom
# --------------------------------------------------

nf() {
	local search
	search=$(fzf-tmux -p --query="$1" -1)
	if [[ -n "$search" ]]; then
			nvim "$search"
	fi
}

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# --------------------------------------------------
# Keybinds
# --------------------------------------------------

bindkey -s "^F" 'nf^M'

# --------------------------------------------------
# Tools
# --------------------------------------------------

if (( $+commands[mise] )); then
  eval "$(mise activate zsh --shims)"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
