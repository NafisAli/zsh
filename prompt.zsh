# =========================================================
# Prompt -- oh-my-posh
# =========================================================

# Guarded so a machine without oh-my-posh still gets a usable shell
# (it falls back to the default prompt rather than erroring on startup).
if command -v oh-my-posh >/dev/null 2>&1; then
  eval "$(oh-my-posh init zsh --config "$ZDOTDIR/themes/catppuccin_mocha.omp.json")"
fi
