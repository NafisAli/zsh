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
# Smart directory navigation & lf
# =========================================================

#LF_ICONS=$(cat ~/.config/lf/icons | tr '\n' ':')
#export LF_ICONS

# Initialize zoxide
eval "$(zoxide init zsh)"

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
# Machine-local overrides
# =========================================================

# Anything in local/ is gitignored: per-machine aliases, work scripts, secrets
# adjacent config. Sourced last so it can override anything set above.
# (N) makes the glob expand to nothing -- not an error -- when local/ is absent.
for _local_rc in "$ZDOTDIR"/local/*.zsh(N); do
  source "$_local_rc"
done
unset _local_rc
