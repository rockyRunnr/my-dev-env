# Repository Guidelines

## Project Structure & Module Organization
This repository is a personal development-environment bundle, not a single application. `nvim/` contains the modern Neovim setup: `nvim/init.lua` loads `lua/options.lua`, `lua/keymaps.lua`, `lua/plugins.lua`, and `lua/lsp.lua`. Root-level files such as `_.vimrc`, `_.tmux.conf`, and `_.gitignore` are template dotfiles meant to be copied into `$HOME`. Small utilities live at the root (`tmux-keep-zoom`, `tmux-resize-screen`, `mycscope`, `mycscope.sh`). `forcherryblack/` and `forcherrybrown/` store keyboard layout JSON and compiled QMK `.hex` outputs.

## Build, Test, and Development Commands
There is no central build system; validate changes in the target tool.

- `cp nvim/init.lua ~/.config/nvim/ && cp nvim/lua/*.lua ~/.config/nvim/lua/`: install the Neovim config locally.
- `nvim`: start Neovim and let `lazy.nvim` bootstrap or sync plugins on first run.
- `vim +PluginInstall +qall`: install legacy Vim plugins for `_.vimrc`.
- `tmux source-file _.tmux.conf`: reload tmux config during manual testing.
- `bash -n tmux-keep-zoom mycscope.sh`: run a quick shell syntax check before committing script changes.

## Coding Style & Naming Conventions
Use 2-space indentation in Lua and keep each module focused on one concern. Follow the existing filename pattern under `nvim/lua/` with clear lowercase module names such as `options.lua` and `keymaps.lua`. Keep shell helpers short, executable, and root-level; prefer lowercase names and hyphens for standalone tools. Preserve the current comment style: concise section headers, sparse inline notes. Long-form docs in `README.md` and `nvim/*.md` are currently Korean, so keep adjacent documentation language consistent.

## Testing Guidelines
There is no automated test suite or coverage threshold. Test Neovim changes by launching `nvim` and confirming startup, plugin install, keymaps, and LSP behavior. Test tmux or Vim updates by reloading the config in a live session. When editing keyboard assets, update the paired `.json` and `.hex` files together and verify the intended board directory.

## Commit & Pull Request Guidelines
Recent history uses Conventional Commit prefixes such as `feat:`, `fix:`, and `docs:`. Keep commit subjects short, imperative, and scoped to one config area. Pull requests should explain which environment is affected (`nvim`, `tmux`, `vim`, or keyboard assets), list manual verification steps, and include screenshots or keymap examples when behavior changes are visible.

## Security & Configuration Tips
Do not commit secrets, machine-specific absolute paths, or host-only aliases. Treat `_`-prefixed files as portable templates and keep repository defaults generic.
