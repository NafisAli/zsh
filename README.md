# zsh config

A modular, XDG-compliant zsh setup for macOS on Apple Silicon. Everything lives in
`~/.config/zsh` — nothing but a three-line bootstrap sits outside this directory.

Plugins are managed by a ~20-line function in `plugins.zsh`, so there is no framework
(no oh-my-zsh, no zinit) to keep up to date. Startup is **~0.12s**.

## Layout

| File | What it owns |
| --- | --- |
| `.zshenv` | XDG base dirs, `EDITOR`/`VISUAL`, `MANPAGER`, `GPG_TTY`, `PATH`. Read by *every* zsh, including scripts. |
| `.zshrc` | History, shell options, zoxide, completion system, fzf key bindings, and the `source` list for everything below. Interactive shells only. |
| `aliases.zsh` | `eza` listing aliases, colourised `diff`, `cd -`, arch-switch shells. |
| `bindings.zsh` | Key bindings. |
| `fzf.zsh` | fzf environment (`fd` as the source, `bat` previews) and the `Ctrl+F` picker widget. |
| `plugins.zsh` | The plugin manager and the plugin list. |
| `node.zsh` | Lazy-loading nvm. |
| `prompt.zsh` | oh-my-posh initialisation. |
| `themes/` | oh-my-posh theme JSON (version-controlled). |
| `plugins/` | Plugin git clones. **Gitignored** — recreated automatically. |

### Load order

```
/etc/zshenv          sets XDG_CONFIG_HOME and ZDOTDIR      (not in this repo — see Install)
  -> $ZDOTDIR/.zshenv
  -> $ZDOTDIR/.zshrc
       -> fzf.zsh -> aliases.zsh -> bindings.zsh -> plugins.zsh -> node.zsh -> prompt.zsh
```

Order matters in one place: the Docker `fpath` entry must precede `compinit`.

## Prerequisites

```bash
brew install eza bat fd ripgrep fzf zoxide neovim oh-my-posh
```

| Tool | Used for | If missing |
| --- | --- | --- |
| `eza` | `ls`/`ll`/`la`/`tree` aliases | those aliases fail |
| `bat` | `MANPAGER`, fzf previews | plain man pages, no previews |
| `fd` | fzf's file source | fzf falls back to `find` |
| `fzf` | `Ctrl+T`, `Ctrl+R`, `Ctrl+F`, `Alt+C` | those bindings do nothing |
| `zoxide` | the `z` command | `.zshrc` errors on startup |
| `oh-my-posh` | the prompt | falls back to the default prompt (guarded, no error) |
| `neovim` | `EDITOR`/`VISUAL` | git/crontab open nothing usable |
| `ripgrep` | `rg` on the PATH | just no `rg` |
| `git` | cloning plugins | plugins never install |

A [Nerd Font](https://www.nerdfonts.com/) is required for the prompt glyphs and eza icons
to render. `oh-my-posh font install` offers an interactive picker; afterwards set the font
in your terminal's preferences.

## Install

**1. Clone the repo.**

```bash
git clone <this-repo> ~/.config/zsh
```

**2. Point zsh at it.** zsh only reads `~/.config/zsh` if `ZDOTDIR` is set *before* any
config is loaded, which means it has to happen in `/etc/zshenv`. This file is deliberately
not in the repo (it is root-owned), and a macOS upgrade can reset it — so keep this snippet
handy:

```bash
sudo tee /etc/zshenv >/dev/null <<'EOF'
if [[ -z "$XDG_CONFIG_HOME" ]]
then
    export XDG_CONFIG_HOME="$HOME/.config"
fi

if [[ -d "$XDG_CONFIG_HOME/zsh" ]]
then
    export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
fi
EOF
```

The `-d` guard means the file is harmless on a machine where the repo isn't cloned yet.

**3. Open a new terminal.** On first start the three plugins clone themselves and the state
and cache directories are created. Expect a few "Installing …" lines once, then nothing.

**4. Verify.**

```bash
echo $ZDOTDIR    # -> /Users/<you>/.config/zsh
```

## Plugins

`plugins.zsh` clones each plugin into `plugins/<name>` on first use and sources
`plugins/<name>/<name>.plugin.zsh`. To add one, append a line:

```zsh
_zplugin_load <github-user> <repo-name>
```

Currently loaded, in order:

| Plugin | What it does |
| --- | --- |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | inline greyed-out suggestion from history |
| [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search) | substring history search on the arrow keys |
| [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting) | command-line syntax colouring |

Update them all:

```bash
zplugin-update
```

Reinstall a broken one by deleting it and starting a new shell:

```bash
rm -rf ~/.config/zsh/plugins/<name>
```

## Node / nvm

`node.zsh` avoids nvm's startup cost, which is **~0.85s per shell** (almost all of it the
implicit `nvm use default` that `nvm.sh` performs when sourced).

Instead it puts the default version's `bin` directory straight onto `PATH`, so `node`,
`npm` and `npx` are available immediately, and defines an `nvm` shim that sources the real
`nvm.sh` on first call and then removes itself. The first `nvm` command in a shell pays the
0.85s once; everything after that is the genuine nvm.

**Trade-off:** a project's `.nvmrc` is *not* applied automatically. Run `nvm use` yourself.

Install nvm itself with the [upstream installer](https://github.com/nvm-sh/nvm#installing-and-updating).
Note two things about how it interacts with this repo:

- Its profile detection is `ZDOTDIR`-aware, so it targets `.zshrc` **in this repo**, not
  `~/.zshrc`. Its skip-guard is a plain substring search for `/nvm.sh` and
  `$NVM_DIR/bash_completion` in that file — which the marker comments above
  `source "$ZDOTDIR/node.zsh"` satisfy. So re-running the installer is a no-op instead of
  appending eager-loading lines. **Don't delete those comments.**
- Set `NVM_DIR` to `$HOME/.nvm` and nothing else. The installer writes an XDG-conditional
  expression that resolves to `$XDG_CONFIG_HOME/nvm`; since `.zshenv` sets
  `XDG_CONFIG_HOME`, that would point at a directory that doesn't exist and nvm would
  silently find no versions.

## Key bindings

| Key | Action |
| --- | --- |
| `Ctrl+T` | fzf file picker, insert path (fzf built-in) |
| `Ctrl+R` | fzf history search (fzf built-in) |
| `Ctrl+F` | fzf file picker excluding hidden files |
| `Alt+C` / `ç` | fzf directory picker, then `cd` |
| `Ctrl+←` / `Ctrl+→` | move back/forward one word |
| `↑` / `↓` | history search by substring |
| `Ctrl+\` | toggle autosuggestions |

On macOS, Option+C emits the literal character `ç` rather than a usable `Alt-C` escape
sequence, which is why `ç` is bound explicitly.

**Adding bindings:** add new `bindkey` calls directly in `bindings.zsh`.

## Aliases

| Alias | Expands to |
| --- | --- |
| `ls` | `eza --icons` |
| `ll` | `eza -lh --icons --git` |
| `la` | `eza -lah --icons --git` |
| `tree` | `eza --tree --icons` |
| `diff` | `diff --color=auto` |
| `df` | `df -h` |
| `-` | `cd -` |
| `x86` | `arch -x86_64 /bin/zsh --login` |
| `arm` | `arch -arm64 /bin/zsh --login` |

`grep` is intentionally left alone. Aliasing it to `rg` looks tempting but breaks
compatibility: `rg` rejects basic-regex syntax like `\|` and `\{n\}`, takes different
flags, and skips hidden and `.gitignore`d files by default — so a habitual `grep -r`
silently returns fewer matches.

## Where state lives

Nothing is written into this directory at runtime, which keeps `git status` clean.

| Path | Contents |
| --- | --- |
| `~/.local/state/zsh/history` | command history (100k entries) |
| `~/.cache/zsh/zcompdump` | compiled completion cache |

Both parent directories are created automatically by `.zshrc` if missing.

## Customising the prompt

The prompt is oh-my-posh, configured by `themes/catppuccin_mocha.omp.json`.

- **Tweak the current theme:** edit that JSON. Changes apply in the next new shell.
- **Use a different theme:** pick one from the [theme gallery](https://ohmyposh.dev/docs/themes),
  save its JSON into `themes/`, and update the `--config` path in `prompt.zsh`.
- **Dump the active config** (e.g. to fork it): `oh-my-posh config export --output my.json`.
- **Switch prompt engines entirely:** replace the `eval` line in `prompt.zsh`.

## Troubleshooting

**Prompt is `user@host ~ %`.** oh-my-posh isn't installed or isn't on `PATH`.
`prompt.zsh` is deliberately guarded, so it degrades to the default rather than erroring.
Run `brew install oh-my-posh`.

**Prompt shows boxes or `?` instead of icons.** Your terminal font isn't a Nerd Font.

**Config isn't loading at all.** Check `echo $ZDOTDIR`. If it's empty, `/etc/zshenv` is
missing or was reset — reapply step 2 of Install.

**A newly installed command doesn't tab-complete.** The completion cache is stale:

```bash
rm ~/.cache/zsh/zcompdump
```

Then open a new shell.

**`Ctrl+F` or the arrow-key history search stopped working.** Something later in
`bindings.zsh` (or a plugin) is overriding the binding. Inspect the live keymap with
`bindkey | grep -i <widget-name>`.

**Startup got slow.** Time it, then bisect:

```bash
for i in 1 2 3; do /usr/bin/time -p zsh -i -c exit; done
```

Expect ~0.12s. Around 1s means nvm is being sourced eagerly — check whether the installer
appended `source "$NVM_DIR/nvm.sh"` to `.zshrc` (see the Node section).

**A plugin broke after an update.** Delete its directory and restart the shell to get a
fresh clone at the current upstream HEAD.
