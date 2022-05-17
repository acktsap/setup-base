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

readonly NEOVIM_DARWIN_AMD64_URL=https://github.com/neovim/neovim/releases/download/v0.7.0/nvim-macos.tar.gz
readonly VUNDLE_VIM_URL=https://github.com/VundleVim/Vundle.vim/archive/master.zip

function main() {
  local ostype=$(get_os_type)
  local url=$(eval echo \$NEOVIM_${ostype}_URL)

  if [[ $(check_bin_installed nvim) != "true" ]]; then
    download "${url}" /tmp/neovim.tar.gz
    extract /tmp/neovim.tar.gz "${INSTALL_PATH}/neovim"
    link "${INSTALL_PATH}/neovim/nvim-osx64/bin/nvim" "${BIN_LINK_PATH}/nvim"
  fi

  if [[ ! -d "$HOME/.vim/bundle/Vundle.vim" ]]; then
    local bundle_dir="$HOME/.vim/bundle"
    if [[ ! -d "${bundle_dir}" ]]; then
      mkdir -p "${bundle_dir}"
    fi

    download "${VUNDLE_VIM_URL}" /tmp/Vundle.vim.zip
    extract /tmp/Vundle.vim.zip "${bundle_dir}"
    mv "${bundle_dir}/Vundle.vim-master" "${bundle_dir}/Vundle.vim"
  fi

  if [[ ! -d "${HOME}/.config/nvim" ]]; then
    mkdir -p "${HOME}/.config" > /dev/null 2>&1
    link "${SCRIPT_HOME}/config" "${HOME}/.config/nvim"
  fi

  if [[ ! -f "${HOME}/.ideavimrc" ]]; then
    link "${SCRIPT_HOME}/ideavimrc" "${HOME}/.ideavimrc"
  fi
}

main "$@"
