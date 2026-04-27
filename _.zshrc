# ==========================================================================
# .zshrc - Cross-platform interactive shell baseline
# ==========================================================================

typeset -U path PATH
path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  /opt/homebrew/bin
  /usr/local/bin
  $path
)

export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt auto_cd
setopt interactive_comments
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt share_history
setopt inc_append_history
setopt extended_history
setopt no_beep

bindkey -v

autoload -Uz colors compinit
colors
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh" 2>/dev/null
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump"

PROMPT='%F{blue}%n@%m%f:%F{green}%~%f %# '

alias vi='nvim'
alias vim='nvim'
alias v='nvim'
alias vimdiff='nvim -d'
alias tm='tmux new-session -A -s main'
alias ll='ls -lah'
alias la='ls -A'
alias gs='git status -sb'
alias gc='git commit'
alias gl='git log --oneline --decorate --graph -20'

load_if_exists() {
  [ -f "$1" ] && source "$1"
}

# fzf shell integration
load_if_exists "/opt/homebrew/opt/fzf/shell/completion.zsh"
load_if_exists "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
load_if_exists "/usr/local/opt/fzf/shell/completion.zsh"
load_if_exists "/usr/local/opt/fzf/shell/key-bindings.zsh"
load_if_exists "/usr/share/fzf/completion.zsh"
load_if_exists "/usr/share/fzf/key-bindings.zsh"
load_if_exists "/usr/share/doc/fzf/examples/completion.zsh"
load_if_exists "/usr/share/doc/fzf/examples/key-bindings.zsh"

# lightweight zsh plugins installed by setup.sh
load_if_exists "$HOME/.local/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
load_if_exists "$HOME/.local/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
