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

readonly OPENSSL_SRC_URL=https://www.openssl.org/source/openssl-1.1.1j.tar.gz
readonly LIBEVENT_SRC_URL=https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz
readonly TMUX_SRC_URL=https://github.com/tmux/tmux/releases/download/3.1c/tmux-3.1c.tar.gz

function main() {
  local ostype=$(get_os_type)
  local url=$(eval echo \$FZF_${ostype}_URL)

  if [[ $(check_lib_installed libssl.dylib) != "true" ]]; then
    download "${OPENSSL_SRC_URL}" /tmp/openssl.tar.gz
    extract /tmp/openssl.tar.gz "${INSTALL_PATH}/openssl"

    # see also: https://gist.github.com/tomasbasham/1e405cfa16e88c0f5d2f49bbbd161944
    echo "-- Installing openssl.."
    pushd "${INSTALL_PATH}/openssl/openssl-1.1.1j" > /dev/null

    if [[ "$ostype" == "DARWIN_AMD64" ]]; then
      ./Configure darwin64-x86_64-cc --prefix=/usr/local --o > /dev/null
      make CFLAGS='-I/usr/local/ssl/include' > /dev/null
      sudo make install > /dev/null
    elif [[ "$ostype" == "DARWIN_ARM64" ]]; then
      ./Configure darwin64-arm64-cc --prefix=/usr/local --o > /dev/null
      make CFLAGS='-I/usr/local/ssl/include' > /dev/null
      sudo make install > /dev/null
    else
      echo "Unsupported os type $ostype"
      exit -1
    fi
  fi

  if [[ $(check_lib_installed libevent) != "true" ]]; then
    download "${LIBEVENT_SRC_URL}" /tmp/libevent.tar.gz
    extract /tmp/libevent.tar.gz "${INSTALL_PATH}/libevent"

    # see also: https://gist.github.com/tomasbasham/1e405cfa16e88c0f5d2f49bbbd161944
    echo "-- Installing libevent.."
    pushd "${INSTALL_PATH}/libevent/libevent-2.1.12-stable" > /dev/null
    ./configure > /dev/null
    make > /dev/null
    sudo make install > /dev/null
    popd > /dev/null
  fi

  if [[ $(check_bin_installed tmux) != "true" ]]; then
    download "${TMUX_SRC_URL}" /tmp/tmux.tar.gz
    extract /tmp/tmux.tar.gz "${INSTALL_PATH}/tmux"

    # https://github.com/tmux/tmux#installation
    # https://github.com/tmux/tmux/wiki/Installing#building-dependencies
    echo "-- Installing tmux.."
    pushd "${INSTALL_PATH}/tmux/tmux-3.1c" > /dev/null
    LDFLAGS="-L/usr/local/lib" CPPFLAGS="-I/usr/local/include" LIBS="-lresolv"
    ./configure > /dev/null
    make > /dev/null 2>&1
    sudo make install prefix=. > /dev/null
    unset LDFLAGS
    popd > /dev/null

    link "${INSTALL_PATH}/tmux/tmux-3.1c/bin/tmux" "${BIN_LINK_PATH}/tmux"
  fi

  if [[ ! -f "${HOME}/.tmux.conf" ]]; then
    link "${SCRIPT_HOME}/tmux.conf" "${HOME}/.tmux.conf"
  fi
}

main "$@"
