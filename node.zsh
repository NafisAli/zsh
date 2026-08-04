# =========================================================
# Node / nvm (lazy)
# =========================================================

# Hardcoded on purpose. nvm's own installer writes an XDG-conditional
# expression that resolves to $XDG_CONFIG_HOME/nvm -- and since .zshenv sets
# XDG_CONFIG_HOME, that would point at ~/.config/nvm, which does not exist.
export NVM_DIR="$HOME/.nvm"

# Put the default version's bin on PATH immediately, so node/npm/npx work in a
# new shell without paying nvm's ~0.85s sourcing cost every time.
if [[ -r "$NVM_DIR/alias/default" ]]; then
  _nvm_default="$(<"$NVM_DIR/alias/default")"
  # alias/default may point at another alias (e.g. "lts") -- resolve one hop
  [[ -r "$NVM_DIR/alias/$_nvm_default" ]] && _nvm_default="$(<"$NVM_DIR/alias/$_nvm_default")"
  [[ "$_nvm_default" == v* ]] || _nvm_default="v$_nvm_default"
  [[ -d "$NVM_DIR/versions/node/$_nvm_default/bin" ]] &&
    path=("$NVM_DIR/versions/node/$_nvm_default/bin" $path)
  unset _nvm_default
fi

# The real nvm is sourced on first use, then the shim removes itself.
# Trade-off: a project .nvmrc is not applied automatically -- run `nvm use`.
nvm() {
  unfunction nvm
  source "$NVM_DIR/nvm.sh"                                    # activates default
  [[ -r "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
  nvm "$@"
}
