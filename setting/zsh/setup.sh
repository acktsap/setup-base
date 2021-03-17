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

readonly OMZ_URL=https://github.com/ohmyzsh/ohmyzsh/archive/master.zip

function main() {
  if [[ $(check_bin_installed direnv) != "true" ]]; then
    # TODO: install zsh
    echo "Zsh is not installed. Install zsh manually."
    exit -1
  fi

  if [[ -z $(echo $SHELL | grep zsh) ]]; then
    echo "-- Setting zsh as default shell.."
    local zshell_location=$(which zsh)
    [ -z $(sudo grep ${zshell_location} /etc/shells) ] && sudo bash -c "echo ${zshell_location} >> /etc/shells"
    chsh -s ${zshell_location}
  fi

  if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
    echo "-- Setting on-my-ash.."
    download "${OMZ_URL}" /tmp/oh-my-zsh.zip
    extract /tmp/oh-my-zsh.zip "${INSTALL_PATH}/oh-my-zsh"
    link "${INSTALL_PATH}/oh-my-zsh/ohmyzsh-master" "${HOME}/.oh-my-zsh"
  fi

  if [[ ! -f "${HOME}/.zshrc" ]]; then
    copy "${SCRIPT_HOME}/zshrc" "${HOME}/.zshrc"
  fi
}

main "$@"