# dotfiles

Shell, git, tmux and vim configuration for remote dev boxes (bash on Linux; also fine on macOS).

## Install

```sh
git clone https://github.com/<your-github-user>/dotfiles ~/.dotfiles
~/.dotfiles/install.sh             # or: install.sh --dry-run to see what would change
```

The installer is idempotent, so re-running it is safe. Open a new shell (or `exec bash -l`) afterwards.

## What gets installed

| Source | Destination | Notes |
|---|---|---|
| `shell/bashrc` | sourced from `~/.bashrc` | One guarded line is appended; the file is never replaced |
| `git/config` | `~/.config/git/config` | Sensible defaults and aliases, no identity |
| `git/ignore` | `~/.config/git/ignore` | Global gitignore |
| `inputrc` | `~/.inputrc` | History prefix search, case-insensitive completion |
| `tmux/tmux.conf` | `~/.tmux.conf` | Mouse, vi keys, panes keep the working directory |
| `vim/vimrc` | `~/.vimrc` | Sane defaults, persistent undo |

`shell/` is split by concern: `exports.sh` (PATH, history, editor), `aliases.sh`, `functions.sh`, `prompt.sh`.

## Behavior guarantees

- **Nothing is overwritten.** A file already in the way is moved to `<name>.dotfiles-bak.<timestamp>`. `~/.bashrc` and `~/.bash_profile` are only appended to, inside `# >>> dotfiles >>>` markers.
- **No identity or secrets.** `git/config` never sets `user.name` or `user.email`. It lives in the XDG config, which git reads before `~/.gitconfig`, so whatever identity is set there always wins.
- **A customized prompt wins.** `prompt.sh` only replaces a stock distro prompt; if something earlier already customized `PS1`, it is left alone.
- **Login shells work.** `install.sh` makes sure `~/.bash_profile` chains to `~/.profile`/`~/.bashrc`, since bash reads it instead of `~/.profile`.

## Machine-local overrides

Anything that should not be committed (work-only aliases, tokens, paths) goes in `~/.bashrc.local`, which is sourced last if it exists. Keep this repo free of internal hostnames, account IDs and credentials, because it is public.

## Try it without touching your real home directory

```sh
tmp=$(mktemp -d)
HOME=$tmp ./install.sh
HOME=$tmp ./install.sh          # second run should report "ok" for everything
HOME=$tmp bash -ic 'type ll'
```
