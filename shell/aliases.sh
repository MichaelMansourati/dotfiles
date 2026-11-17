# shellcheck shell=bash
# Aliases. Functions live in functions.sh.

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

if ls --color=auto >/dev/null 2>&1; then
  alias ls='ls --color=auto'
else
  alias ls='ls -G'
fi
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias c='clear'
alias h='history | tail -50'
alias reload='exec bash -l'
alias ws='cd ~/workspace'

# git (more aliases live in git/config)
alias g='git'
alias gst='git status -sb'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git lg'
alias gco='git checkout'
alias gsw='git switch'

# kubernetes
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgn='kubectl get nodes'
alias kdp='kubectl describe pod'
alias klf='kubectl logs -f'
