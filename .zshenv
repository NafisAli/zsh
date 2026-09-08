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
# Deduplicate entries while preserving first occurrence
typeset -U path PATH

# Common directories added conditionally if they exist.
# (N) null-glob drops nonexistent paths cleanly across OSes (macOS, Linux, etc.)
path=(
  "$HOME/.local/bin"(N)
  "$HOME/.local/share/mise/shims"(N)
  "$HOME/.opencode/bin"(N)
  "$HOME/.cargo/bin"(N)
  "$HOME/.bun/bin"(N)
  "$HOME/.local/share/pnpm"(N)
  /opt/homebrew/bin(N)
  /opt/homebrew/sbin(N)
  /home/linuxbrew/.linuxbrew/bin(N)
  /home/linuxbrew/.linuxbrew/sbin(N)
  $path
)
export PATH
