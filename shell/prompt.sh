# shellcheck shell=bash
# Prompt. Only replace a stock prompt: if something earlier in the startup files already
# customized PS1, leave it alone.
case "$PS1" in
  '${debian_chroot:+($debian_chroot)}\u@\h:\w\$ ' | '\s-\v\$ ' | '\h:\W \u\$ ') ;;
  *) return 0 ;;
esac

# Current branch (or short SHA when detached). No dirty marker: `git status` is too slow
# on large repos to run before every prompt.
__prompt_branch() {
  local b
  b="$(git branch --show-current 2>/dev/null)"
  if [ -z "$b" ]; then b="$(git rev-parse --short HEAD 2>/dev/null)"; fi
  if [ -n "$b" ]; then printf ' (%s)' "$b"; fi
  return 0
}

PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\w\[\e[33m\]$(__prompt_branch)\[\e[0m\]\$ '
