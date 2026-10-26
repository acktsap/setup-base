#!/bin/bash -e

if [[ "$OSTYPE" != darwin* ]]; then
  echo "Skip Colima service unregistration: macOS only"
  exit 0
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew must be installed first" >&2
  exit 1
fi

brew services stop colima
