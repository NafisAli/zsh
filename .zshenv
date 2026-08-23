# ~/.config/zsh/.zshenv

# ---------- XDG base directories ----------
# Centralizes config/cache/data locations
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# ---------- Editor ----------
# Default editor used by git, crontab, etc.
export EDITOR="nvim"
export VISUAL="nvim"

# ---------- Pager ----------
if command -v bat >/dev/null 2>&1; then
 export MANPAGER="bat -l man -p"
elif command -v batcat >/dev/null 2>&1; then
 export MANPAGER="batcat -l man -p"
fi

# ---------- GPG ----------
# $TTY is set by zsh itself, so this avoids forking `tty` on every shell start
# (.zshenv runs for scripts and hooks too). In a non-interactive shell it is
# empty, which gpg treats as unset -- unlike `$(tty)`, which yields "not a tty".
export GPG_TTY=$TTY

# ---------- PATH ----------
# mise version manager shims
[[ -d "$HOME/.local/share/mise/shims" ]] && export PATH="$HOME/.local/share/mise/shims:$PATH"

# Personal binaries/scripts
export PATH="$HOME/.local/bin:$PATH"

