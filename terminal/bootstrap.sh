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


. $SCRIPT_HOME/common

#######################################
# Install Homebrew on macOS so the install() helper has a package manager.
#######################################
function install_brew() {
  # Detect by real install path, not PATH: this runs in a non-interactive
  # shell where /opt/homebrew/bin may not be on PATH yet even if brew exists.
  local brew_bin=""
  if command -v brew > /dev/null 2>&1; then
    brew_bin="$(command -v brew)"
  elif [[ -x /opt/homebrew/bin/brew ]]; then
    brew_bin="/opt/homebrew/bin/brew"
  elif [[ -x /usr/local/bin/brew ]]; then
    brew_bin="/usr/local/bin/brew"
  fi

  if [[ -n "$brew_bin" ]]; then
    echo "Homebrew already installed"
    eval "$("$brew_bin" shellenv)"
    return
  fi

  echo "Installing Homebrew.."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Make brew available in the current shell for subsequent setup steps
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

function main() {
  if [[ "$OSTYPE" = darwin* ]]; then
    install_brew
  fi
}

main "$@"
