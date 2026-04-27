#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
SKIP_PACKAGES=0
SKIP_PLUGINS=0
SET_DEFAULT_SHELL=0
SET_SYSTEM_ALTERNATIVES=0

usage() {
  cat <<'EOF'
Usage: ./setup.sh [options]

Options:
  --dry-run                  Print the actions without changing the system
  --skip-packages            Skip package-manager installs
  --skip-plugins             Skip TPM / zsh plugin / Neovim plugin bootstrap
  --set-default-shell        Run chsh so the login shell becomes zsh
  --set-system-alternatives  On Linux, point vi/vim/editor alternatives to nvim
  -h, --help                 Show this help
EOF
}

log() {
  printf '[setup] %s\n' "$*"
}

warn() {
  printf '[setup] WARN: %s\n' "$*" >&2
}

die() {
  printf '[setup] ERROR: %s\n' "$*" >&2
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

run_cmd() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

run_shell() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run] %s\n' "$1"
  else
    /bin/sh -c "$1"
  fi
}

run_as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    run_cmd "$@"
  elif command_exists sudo; then
    if [ "$DRY_RUN" -eq 1 ]; then
      printf '[dry-run]'
      printf ' %q' sudo "$@"
      printf '\n'
    else
      sudo "$@"
    fi
  else
    die "sudo is required for: $*"
  fi
}

backup_existing() {
  local target backup
  target=$1

  if [ ! -e "$target" ] && [ ! -L "$target" ]; then
    return 0
  fi

  backup="${target}.backup.${TIMESTAMP}"
  log "Backing up $target -> $backup"
  run_cmd mv "$target" "$backup"
}

ensure_symlink() {
  local source target current
  source=$1
  target=$2

  run_cmd mkdir -p "$(dirname "$target")"

  if [ -L "$target" ]; then
    current=$(readlink "$target" 2>/dev/null || true)
    if [ "$current" = "$source" ]; then
      log "Already linked: $target"
      return 0
    fi
  fi

  if [ -e "$target" ] || [ -L "$target" ]; then
    backup_existing "$target"
  fi

  log "Linking $target -> $source"
  run_cmd ln -s "$source" "$target"
}

detect_package_manager() {
  if command_exists brew; then
    printf 'brew\n'
  elif command_exists apt-get; then
    printf 'apt\n'
  elif command_exists zypper; then
    printf 'zypper\n'
  else
    printf 'none\n'
  fi
}

install_brew_packages() {
  local pkg
  local packages
  local optional
  local missing

  packages=(git zsh tmux neovim ripgrep fzf)
  optional=(cscope universal-ctags)
  missing=()

  for pkg in "${packages[@]}"; do
    if ! brew list --formula "$pkg" >/dev/null 2>&1; then
      missing+=("$pkg")
    fi
  done

  if [ "${#missing[@]}" -gt 0 ]; then
    log "Installing Homebrew packages: ${missing[*]}"
    run_cmd brew install "${missing[@]}"
  else
    log "Required Homebrew packages already installed"
  fi

  for pkg in "${optional[@]}"; do
    if ! brew list --formula "$pkg" >/dev/null 2>&1; then
      log "Installing optional Homebrew package: $pkg"
      run_cmd brew install "$pkg" || warn "Could not install optional package: $pkg"
    fi
  done
}

install_apt_packages() {
  local packages

  packages=(git zsh tmux neovim ripgrep fzf curl)

  log "Updating apt package index"
  run_as_root apt-get update

  log "Installing apt packages: ${packages[*]}"
  run_as_root apt-get install -y "${packages[@]}"

  if command_exists apt-cache && apt-cache show cscope >/dev/null 2>&1; then
    run_as_root apt-get install -y cscope || warn "Could not install optional package: cscope"
  fi

  if command_exists apt-cache && apt-cache show universal-ctags >/dev/null 2>&1; then
    run_as_root apt-get install -y universal-ctags || warn "Could not install optional package: universal-ctags"
  fi
}

install_zypper_packages() {
  local packages

  packages=(git zsh tmux neovim ripgrep fzf curl)

  log "Installing zypper packages: ${packages[*]}"
  run_as_root zypper --non-interactive install "${packages[@]}"

  run_as_root zypper --non-interactive install cscope || warn "Could not install optional package: cscope"
  run_as_root zypper --non-interactive install universal-ctags || warn "Could not install optional package: universal-ctags"
}

install_packages() {
  local manager
  manager=$(detect_package_manager)

  case "$manager" in
    brew) install_brew_packages ;;
    apt) install_apt_packages ;;
    zypper) install_zypper_packages ;;
    none) warn "No supported package manager found. Install zsh, tmux, neovim, git, ripgrep, and fzf manually." ;;
  esac
}

install_git_repo_if_missing() {
  local url dest
  url=$1
  dest=$2

  if [ -d "$dest/.git" ]; then
    log "Already present: $dest"
    return 0
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    backup_existing "$dest"
  fi

  run_cmd mkdir -p "$(dirname "$dest")"
  log "Cloning $url -> $dest"
  run_cmd git clone --depth 1 "$url" "$dest"
}

link_repo_files() {
  ensure_symlink "$REPO_DIR/_.zshrc" "$HOME/.zshrc"
  ensure_symlink "$REPO_DIR/_.tmux.conf" "$HOME/.tmux.conf"
  ensure_symlink "$REPO_DIR/_.vimrc" "$HOME/.vimrc"
  ensure_symlink "$REPO_DIR/nvim" "$HOME/.config/nvim"

  run_cmd mkdir -p "$HOME/bin"
  ensure_symlink "$REPO_DIR/tmux-keep-zoom" "$HOME/bin/tmux-keep-zoom"
  ensure_symlink "$REPO_DIR/tmux-resize-screen" "$HOME/bin/tmux-resize-screen"
  ensure_symlink "$REPO_DIR/mycscope" "$HOME/bin/mycscope"
}

link_nvim_wrappers() {
  local nvim_path

  if ! command_exists nvim; then
    warn "nvim is not installed yet; skipping vi/vim wrappers"
    return 0
  fi

  nvim_path=$(command -v nvim)
  run_cmd mkdir -p "$HOME/bin"

  ensure_symlink "$nvim_path" "$HOME/bin/vi"
  ensure_symlink "$nvim_path" "$HOME/bin/vim"
  ensure_symlink "$nvim_path" "$HOME/bin/editor"
}

configure_default_shell() {
  local zsh_path

  zsh_path=$(command -v zsh || true)
  if [ -z "$zsh_path" ]; then
    warn "zsh is not installed; cannot change login shell"
    return 0
  fi

  if [ "${SHELL:-}" = "$zsh_path" ]; then
    log "Login shell already uses zsh"
    return 0
  fi

  if [ -r /etc/shells ] && ! grep -qx "$zsh_path" /etc/shells; then
    warn "$zsh_path is not listed in /etc/shells; skipping chsh"
    return 0
  fi

  log "Changing login shell to $zsh_path"
  run_cmd chsh -s "$zsh_path"
}

configure_system_alternatives() {
  local nvim_path
  local alt

  if ! command_exists update-alternatives; then
    warn "update-alternatives is not available on this system; skipping system vi/vim/editor setup"
    return 0
  fi

  if ! command_exists nvim; then
    warn "nvim is not installed; cannot configure update-alternatives"
    return 0
  fi

  nvim_path=$(command -v nvim)

  for alt in editor vi vim; do
    run_as_root update-alternatives --install "/usr/bin/$alt" "$alt" "$nvim_path" 80 || warn "Could not register alternative: $alt"
    run_as_root update-alternatives --set "$alt" "$nvim_path" || warn "Could not select alternative: $alt"
  done
}

bootstrap_tmux_plugins() {
  install_git_repo_if_missing "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm"

  if [ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
    log "Installing tmux plugins via TPM"
    if ! run_cmd "$HOME/.tmux/plugins/tpm/bin/install_plugins"; then
      warn "TPM plugin install failed"
    fi
  fi
}

bootstrap_zsh_plugins() {
  install_git_repo_if_missing "https://github.com/zsh-users/zsh-autosuggestions" "$HOME/.local/share/zsh/plugins/zsh-autosuggestions"
  install_git_repo_if_missing "https://github.com/zsh-users/zsh-syntax-highlighting" "$HOME/.local/share/zsh/plugins/zsh-syntax-highlighting"
}

check_nvim_version() {
  local version major minor

  if ! command_exists nvim; then
    warn "nvim is not installed"
    return 0
  fi

  version=$(nvim --version | awk 'NR==1 {sub(/^v/, "", $2); sub(/^NVIM/, "", $2); print $2}')
  major=$(printf '%s' "$version" | cut -d. -f1)
  minor=$(printf '%s' "$version" | cut -d. -f2)

  if [ "$major" -eq 0 ] && [ "$minor" -lt 10 ]; then
    warn "Neovim $version is too old for this repo. Install 0.10+."
  else
    log "Detected Neovim $version"
  fi
}

bootstrap_nvim_plugins() {
  if ! command_exists nvim; then
    warn "nvim is not installed; skipping plugin bootstrap"
    return 0
  fi

  check_nvim_version

  log "Bootstrapping Neovim plugins"
  if ! run_shell 'nvim --headless "+Lazy! sync" +qa'; then
    warn "Neovim plugin bootstrap failed. Re-run after verifying network access and plugin prerequisites."
  fi
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --skip-packages) SKIP_PACKAGES=1 ;;
      --skip-plugins) SKIP_PLUGINS=1 ;;
      --set-default-shell) SET_DEFAULT_SHELL=1 ;;
      --set-system-alternatives) SET_SYSTEM_ALTERNATIVES=1 ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "Unknown option: $1"
        ;;
    esac
    shift
  done
}

main() {
  parse_args "$@"

  log "Repository: $REPO_DIR"

  if [ "$SKIP_PACKAGES" -eq 0 ]; then
    install_packages
  else
    log "Skipping package installs"
  fi

  link_repo_files
  link_nvim_wrappers

  if [ "$SET_DEFAULT_SHELL" -eq 1 ]; then
    configure_default_shell
  fi

  if [ "$SET_SYSTEM_ALTERNATIVES" -eq 1 ]; then
    configure_system_alternatives
  fi

  if [ "$SKIP_PLUGINS" -eq 0 ]; then
    bootstrap_zsh_plugins
    bootstrap_tmux_plugins
    bootstrap_nvim_plugins
  else
    log "Skipping plugin bootstrap"
  fi

  log "Done"
  log "Open a new shell or run: exec zsh"
}

main "$@"
