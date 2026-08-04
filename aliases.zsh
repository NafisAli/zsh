# Better ls
alias ls='eza --icons'

# Detailed listing
alias ll='eza -lh --icons --git'

# Detailed listing including hidden files
alias la='eza -lah --icons --git'

# Tree view
alias tree='eza --tree --icons'

# Reuse ls completions for eza (avoids defining a separate completion function)
compdef eza=ls

# =========================================================
# Core utilities
# =========================================================

alias diff='diff --color=auto'
alias df='df -h'

# grep is deliberately NOT aliased to rg: rg rejects BRE syntax (\| \{n\}),
# has a different flag set, and skips hidden and .gitignore'd files by default.

# =========================================================
# Navigation
# =========================================================

alias -- -='cd -'  # -- prevents - being parsed as a flag; cd - jumps to previous directory

# =========================================================
# Architecture shells (Apple Silicon)
# =========================================================

alias x86='arch -x86_64 /bin/zsh --login'
alias arm='arch -arm64 /bin/zsh --login'

