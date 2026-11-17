# shellcheck shell=bash
# Small helper functions.

# mkcd DIR: create DIR and cd into it.
mkcd() { mkdir -p -- "$1" && cd -- "$1" || return; }

# up [N]: cd up N directories (default 1).
up() {
  local n=${1:-1} p=""
  while [ "$n" -gt 0 ]; do
    p="../$p"
    n=$((n - 1))
  done
  cd "${p:-.}" || return
}

# cdr: cd to the root of the current git repository.
cdr() { cd "$(git rev-parse --show-toplevel)" || return; }

# bak FILE: copy FILE to FILE.bak.<timestamp>.
bak() { cp -a -- "$1" "$1.bak.$(date +%Y%m%d%H%M%S)"; }

# path: print PATH one entry per line.
path() { printf '%s\n' "${PATH//:/$'\n'}"; }

# psg PATTERN: find processes by name (the bracket trick keeps grep out of its own results).
psg() { ps aux | grep -i -- "[${1:0:1}]${1:1}"; }

# portcheck PORT: show what is listening on PORT.
portcheck() {
  if command -v ss >/dev/null 2>&1; then
    ss -ltnp "sport = :$1"
  else
    lsof -nP -iTCP:"$1" -sTCP:LISTEN
  fi
}

# serve [PORT]: serve the current directory over HTTP (default 8000).
serve() { python3 -m http.server "${1:-8000}"; }

# extract FILE: unpack common archive formats.
extract() {
  case "$1" in
    *.tar.gz | *.tgz) tar -xzf "$1" ;;
    *.tar.bz2 | *.tbz2) tar -xjf "$1" ;;
    *.tar.xz) tar -xJf "$1" ;;
    *.tar) tar -xf "$1" ;;
    *.zip) unzip "$1" ;;
    *.gz) gunzip "$1" ;;
    *) echo "extract: don't know how to unpack '$1'" >&2; return 1 ;;
  esac
}
