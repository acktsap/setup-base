#!/bin/bash -e

# Resolve script home
SOURCE="${BASH_SOURCE[0]}"
# resolve $SOURCE until the file is no longer a symlink
while [ -h "$SOURCE" ]; do
  SCRIPT_HOME="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  [[ $SOURCE != /* ]] && SOURCE="$SCRIPT_HOME/$SOURCE"
done
SCRIPT_HOME="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"


. $SCRIPT_HOME/../common

# https://github.com/neovim/neovim/releases
readonly NEOVIM_DARWIN_AMD64_URL="https://github.com/neovim/neovim/releases/download/v0.12.1/nvim-macos-x86_64.tar.gz"
readonly NEOVIM_DARWIN_ARM64_URL="https://github.com/neovim/neovim/releases/download/v0.12.1/nvim-macos-arm64.tar.gz"

readonly NEOVIM_DARWIN_AMD64_DIR_PATH="neovim/nvim-macos-x86_64/bin/nvim"
readonly NEOVIM_DARWIN_ARM64_DIR_PATH="neovim/nvim-macos-arm64/bin/nvim"

readonly VUNDLE_VIM_REPO=https://github.com/VundleVim/Vundle.vim.git

function main() {
  local ostype=$(get_os_type)
  local url=$(eval echo \$NEOVIM_${ostype}_URL)

  if [[ $(check_bin_installed nvim) != "true" ]]; then
    download "${url}" "$TMPDIR/neovim.tar.gz"
    extract "$TMPDIR/neovim.tar.gz" "${INSTALL_PATH}/neovim"
    local DIR_PATH=$(eval echo \$NEOVIM_${ostype}_DIR_PATH)
    link "${INSTALL_PATH}/${DIR_PATH}" "${BIN_LINK_PATH}/nvim"
  fi

  if [[ ! -d "$HOME/.vim/bundle/Vundle.vim" ]]; then
    mkdir -p "$HOME/.vim/bundle"
    git clone "${VUNDLE_VIM_REPO}" "$HOME/.vim/bundle/Vundle.vim"
  fi

  if [[ ! -d "${HOME}/.config/nvim" ]]; then
    mkdir -p "${HOME}/.config" > /dev/null 2>&1
    link "${SCRIPT_HOME}/config" "${HOME}/.config/nvim"
  fi

  # LSP servers
  if [[ $(check_bin_installed clangd) != "true" ]]; then
    install llvm                  # C/C++
  fi
  if [[ $(check_bin_installed gopls) != "true" ]]; then
    go install golang.org/x/tools/gopls@latest  # Go
  fi
  if [[ $(check_bin_installed jdtls) != "true" ]]; then
    install jdtls                 # Java
  fi
  if [[ $(check_bin_installed bash-language-server) != "true" ]]; then
    install bash-language-server  # Shell script
  fi

  # Vundle plugins
  nvim +PluginInstall +qall

  if [[ ! -f "${HOME}/.ideavimrc" ]]; then
    link "${SCRIPT_HOME}/ideavimrc" "${HOME}/.ideavimrc"
  fi
}

main "$@"
