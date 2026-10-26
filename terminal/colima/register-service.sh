#!/bin/bash -e

if [[ "$OSTYPE" != darwin* ]]; then
  echo "Skip Colima service registration: macOS only"
  exit 0
fi

if ! command -v brew >/dev/null 2>&1 || ! command -v colima >/dev/null 2>&1; then
  echo "Colima and Homebrew must be installed first" >&2
  exit 1
fi

brew services start colima
