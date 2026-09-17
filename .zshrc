# =========================================================
# Ghostty shell integration
# =========================================================

# Ghostty injects its integration by launching zsh with ZDOTDIR pointed at its
# own directory, whose .zshenv restores the real ZDOTDIR and loads the
# integration. macOS /etc/zshenv runs first and unconditionally re-exports
# ZDOTDIR whenever $XDG_CONFIG_HOME/zsh exists -- which clobbers Ghostty's
# value, so its .zshenv is never read and the integration silently never loads.
# Sourcing it by hand is the documented fallback; the guard makes it a no-op
# outside Ghostty. Without this, ssh-terminfo never pushes xterm-ghostty to
# remote hosts and every ssh session lands with a broken TERM.
if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
  source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
fi

# =========================================================
# History
# =========================================================

HISTFILE="$XDG_STATE_HOME/zsh/history"
# zsh silently discards history if the directory is missing (fresh machine)
[[ -d "${HISTFILE:h}" ]] || mkdir -p "${HISTFILE:h}"

HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

# =========================================================
# Shell behaviour
# =========================================================

setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT  # sort file10 after file9, not after file1


# =========================================================
# Completion
# =========================================================

# Third-party completion functions must be on fpath before compinit runs.
# Docker Desktop CLI completions (no-op on machines without Docker).
[[ -d "$HOME/.docker/completions" ]] && fpath=("$HOME/.docker/completions" $fpath)

# Load completion system
autoload -Uz compinit

# Initialize completion with cached metadata file
_zcompdump="$XDG_CACHE_HOME/zsh/zcompdump"
[[ -d "${_zcompdump:h}" ]] || mkdir -p "${_zcompdump:h}"
compinit -d "$_zcompdump"
unset _zcompdump

# Enable interactive completion menu selection
zstyle ':completion:*' menu select

# Make completion case-insensitive
# Example: "doc" can complete to "Documents"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # lowercase input matches upper and lower

# =========================================================
# Fuzzy finder
# =========================================================

# macOS / Homebrew (Apple Silicon) or Linux
if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
  source /opt/homebrew/opt/fzf/shell/completion.zsh
elif [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
  source /usr/share/fzf/key-bindings.zsh
  source /usr/share/fzf/completion.zsh
elif command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi


# =========================================================
# Modular Config Files
# =========================================================

# fzf configuration
source "$ZDOTDIR/fzf.zsh"

# Aliases
source "$ZDOTDIR/aliases.zsh"

# Custom keybindings
source "$ZDOTDIR/bindings.zsh"

# Plugins and plugin manager
source "$ZDOTDIR/plugins.zsh"

# Node/nvm -- lazy-loaded, see node.zsh.
# The two markers below make nvm's install.sh detect nvm as already configured,
# so re-running the installer won't append eager-loading lines to this file:
#   [ -s "$NVM_DIR/nvm.sh" ]  and  [ -s "$NVM_DIR/bash_completion" ]
source "$ZDOTDIR/node.zsh"

# Prompt/theme
source "$ZDOTDIR/prompt.zsh"

# =========================================================
# Smart directory navigation (zoxide)
# =========================================================

# Initialize zoxide (must run after compinit for completions to work)
eval "$(zoxide init zsh)"


# =========================================================
# Machine-local overrides
# =========================================================

# Anything in local/ is gitignored: per-machine aliases, work scripts, secrets
# adjacent config. Sourced last so it can override anything set above.
# (N) makes the glob expand to nothing -- not an error -- when local/ is absent.
for _local_rc in "$ZDOTDIR"/local/*.zsh(N); do
  source "$_local_rc"
done
unset _local_rc
