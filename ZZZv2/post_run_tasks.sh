#!/bin/bash

cleanup_system() {
  echo "Cleaning up..."
  if ! apt autoremove -y || ! apt autoclean -y; then
    echo "Cleanup failed." >&2
    exit 1
  fi
}

cleanup_system
