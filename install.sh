#!/usr/bin/env bash
# Install these dotfiles into $HOME. Idempotent and non-destructive: safe to re-run.
#
#   ./install.sh             install
#   ./install.sh --dry-run   print what would change and write nothing
#
# Nothing is overwritten: a file that is in the way is moved to
# <name>.dotfiles-bak.<timestamp>, and ~/.bashrc / ~/.bash_profile are only appended to.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d%H%M%S)"
DRY_RUN=0

case "${1:-}" in
  "") ;;
  --dry-run | -n) DRY_RUN=1 ;;
  -h | --help)
    sed -n '2,8p' "$0"
    exit 0
    ;;
  *)
    echo "usage: $0 [--dry-run]" >&2
    exit 2
    ;;
esac

say() { printf '  %s\n' "$*"; }

# Write a path into an rc file as $HOME-relative when it lives under $HOME.
rc_path() {
  case "$1" in
    "$HOME"/*) printf '$HOME/%s' "${1#"$HOME"/}" ;;
    *) printf '%s' "$1" ;;
  esac
}

# link SRC DEST: make DEST a symlink to SRC, moving anything already there aside.
link() {
  local src=$1 dest=$2
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    say "ok        $dest"
    return
  fi
  if [ "$DRY_RUN" = 1 ]; then
    if [ -e "$dest" ] || [ -L "$dest" ]; then
      say "[dry-run] back up $dest, then link it to $src"
    else
      say "[dry-run] link $dest -> $src"
    fi
    return
  fi
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mv "$dest" "$dest.dotfiles-bak.$STAMP"
    say "backed up $dest -> $dest.dotfiles-bak.$STAMP"
  fi
  ln -s "$src" "$dest"
  say "linked    $dest -> $src"
}

MARK_BEGIN='# >>> dotfiles >>>'
MARK_END='# <<< dotfiles <<<'

# append_block FILE BODY: append BODY between marker lines, once. Creates FILE if missing.
append_block() {
  local file=$1 body=$2
  if [ -f "$file" ] && grep -qxF -- "$MARK_BEGIN" "$file"; then
    say "ok        $file"
    return
  fi
  if [ "$DRY_RUN" = 1 ]; then
    say "[dry-run] append dotfiles block to $file"
    return
  fi
  printf '\n%s\n%s\n%s\n' "$MARK_BEGIN" "$body" "$MARK_END" >>"$file"
  say "appended  $file"
}

echo "Installing dotfiles from $DOTFILES"
if [ "$DRY_RUN" = 1 ]; then echo "(dry run: nothing will be written)"; fi

link "$DOTFILES/inputrc" "$HOME/.inputrc"
link "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"
link "$DOTFILES/vim/vimrc" "$HOME/.vimrc"

# Shared git settings go in the XDG config, never ~/.gitconfig, so the identity that
# `git config --global` writes there (name/email) is left alone and still wins.
link "$DOTFILES/git/config" "${XDG_CONFIG_HOME:-$HOME/.config}/git/config"
link "$DOTFILES/git/ignore" "${XDG_CONFIG_HOME:-$HOME/.config}/git/ignore"

shell_entry="$(rc_path "$DOTFILES")/shell/bashrc"
append_block "$HOME/.bashrc" "if [ -r \"$shell_entry\" ]; then . \"$shell_entry\"; fi"

# bash reads ~/.bash_profile *instead of* ~/.profile for login shells. If one exists (or is
# created later by another tool) without chaining to them, login shells would skip ~/.bashrc.
if [ ! -e "$HOME/.bash_profile" ] || ! grep -qE '\.profile|\.bashrc' "$HOME/.bash_profile"; then
  append_block "$HOME/.bash_profile" 'if [ -f "$HOME/.profile" ]; then . "$HOME/.profile"; elif [ -f "$HOME/.bashrc" ]; then . "$HOME/.bashrc"; fi'
else
  say "ok        $HOME/.bash_profile"
fi

echo
echo "Per-machine overrides go in ~/.bashrc.local; your git identity stays in ~/.gitconfig."
