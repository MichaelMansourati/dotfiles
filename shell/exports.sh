# shellcheck shell=bash
# Environment, history and shell options.

# path_prepend DIR: put DIR first on PATH if it exists and is not already there.
path_prepend() {
  case ":$PATH:" in *":$1:"*) return 0 ;; esac
  if [ -d "$1" ]; then PATH="$1:$PATH"; fi
  return 0
}
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"
export PATH

if command -v vim >/dev/null 2>&1; then
  export EDITOR=vim VISUAL=vim
else
  export EDITOR=vi VISUAL=vi
fi
export PAGER=less LESS='-FRX'

# Colors
export CLICOLOR=1
if command -v dircolors >/dev/null 2>&1; then eval "$(dircolors -b)"; fi

# History: big, shared across sessions, no duplicates, written after every command.
HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT='%F %T  '
shopt -s histappend cmdhist checkwinsize
case "${PROMPT_COMMAND:-}" in
  *"history -a"*) ;;
  *) PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}" ;;
esac

# Free Ctrl-S / Ctrl-Q from terminal flow control.
if [ -t 0 ]; then stty -ixon 2>/dev/null || true; fi
